class CaseRulesEngine
  class ValidationError < StandardError; end

  # Models the LLM is allowed to reference, mapped to their AR classes
  ALLOWED_MODELS = {
    "Case" => Case,
    "Evidence" => Evidence,
    "Action" => Action,
    "CaseNote" => CaseNote,
    "Correspondence" => Correspondence,
    "EvidenceRequest" => EvidenceRequest,
    "EvidenceRequestItem" => EvidenceRequestItem
  }.freeze

  # Attributes the LLM is allowed to set per model
  ALLOWED_ATTRS = {
    "Case" => %w[status priority risk_score],
    "Evidence" => %w[status notes reviewed_at],
    "Action" => %w[title description action_type status due_date blocked_by caseworker_guidance case_id policy_reference_id],
    "CaseNote" => %w[content note_type visible_to_applicant case_id caseworker_id],
    "Correspondence" => %w[subject body channel direction policy_explanation guidance_url action_id policy_reference_id],
    "EvidenceRequest" => %w[cover_message deadline notify_via status case_id requested_by_id],
    "EvidenceRequestItem" => %w[reason submission_method status evidence_id evidence_request_id policy_reference_id]
  }.freeze

  # Valid Case status transitions (from => [to, ...])
  VALID_CASE_TRANSITIONS = {
    "submitted"         => %w[assigned withdrawn],
    "assigned"          => %w[in_review withdrawn],
    "in_review"         => %w[awaiting_evidence ready_for_decision withdrawn],
    "awaiting_evidence" => %w[in_review ready_for_decision withdrawn],
    "ready_for_decision" => %w[decided_approved decided_refused in_review withdrawn]
  }.freeze

  ALLOWED_OPS = %w[update create].freeze

  def initialize(case_record, llm_service: nil)
    @case = case_record
    @llm = llm_service || LlmService.new
  end

  # Evaluates the case and returns proposed operations without applying them.
  # Returns:
  #   {
  #     operations: [{ op:, model:, id:, attrs:, valid:, errors: }],
  #     raw_response: String,
  #     metadata: { model:, tokens_used:, elapsed: }
  #   }
  def evaluate!
    case_data = serialize_case
    config = @case.case_type_config
    rules = load_rules(config)

    result = @llm.evaluate_case!(case_data: case_data, rules: rules)

    operations = result[:operations].map { |op| validate_operation(op) }

    log_evaluation!(result[:raw_response], operations, result[:metadata])

    {
      operations: operations,
      raw_response: result[:raw_response],
      metadata: result[:metadata]
    }
  end

  # Evaluates and applies valid operations inside a transaction.
  # Returns the same hash as evaluate!, with :applied_count added.
  def evaluate_and_apply!
    evaluation = evaluate!
    valid_ops = evaluation[:operations].select { |op| op[:valid] }

    applied_count = 0
    ActiveRecord::Base.transaction do
      valid_ops.each do |op|
        apply_operation!(op)
        applied_count += 1
      end
    end

    evaluation.merge(applied_count: applied_count)
  end

  # Applies a single pre-validated operation set (for human-in-the-loop confirm).
  def apply_operations!(operations)
    valid_ops = operations.select { |op| op[:valid] }
    applied_count = 0

    ActiveRecord::Base.transaction do
      valid_ops.each do |op|
        apply_operation!(op)
        applied_count += 1
      end
    end

    applied_count
  end

  private

  # ── Serialization ──────────────────────────────────────────

  def serialize_case
    @case.as_json(
      include: {
        evidences: { include: :policy_reference },
        actions: { include: :policy_reference },
        case_notes: {},
        evidence_requests: { include: :evidence_request_items }
      }
    )
  end

  def load_rules(config)
    {
      decision_tree_md: config.decision_tree_md,
      state_transitions_md: config.state_transitions_md,
      evidence_requirements_md: config.evidence_requirements_md,
      risk_scoring_md: config.risk_scoring_md
    }
  end

  # ── Validation ─────────────────────────────────────────────

  def validate_operation(op)
    errors = []
    op = op.transform_keys(&:to_s)

    operation = op["op"]
    model_name = op["model"]
    record_id = op["id"]
    attrs = (op["attrs"] || {}).transform_keys(&:to_s)

    # Check operation type
    unless ALLOWED_OPS.include?(operation)
      errors << "Unknown operation: #{operation}"
    end

    # Check model allowlist
    klass = ALLOWED_MODELS[model_name]
    unless klass
      errors << "Model not allowed: #{model_name}"
    end

    if klass && attrs.any?
      # Check attribute allowlist
      allowed = ALLOWED_ATTRS[model_name] || []
      disallowed = attrs.keys - allowed
      errors << "Disallowed attributes for #{model_name}: #{disallowed.join(', ')}" if disallowed.any?

      # Validate enum values
      attrs.each do |attr, value|
        if klass.defined_enums.key?(attr)
          unless klass.defined_enums[attr].key?(value.to_s)
            errors << "Invalid enum value '#{value}' for #{model_name}##{attr}. " \
                      "Valid: #{klass.defined_enums[attr].keys.join(', ')}"
          end
        end
      end

      # Validate Case status transitions
      if model_name == "Case" && attrs.key?("status")
        validate_case_transition!(attrs["status"], errors)
      end
    end

    # For updates, verify the record belongs to this case
    if operation == "update" && klass && record_id
      validate_record_ownership!(klass, model_name, record_id, errors)
    end

    # For creates, inject/verify case_id linkage
    if operation == "create" && klass && attrs.any?
      validate_create_linkage!(model_name, attrs, errors)
    end

    {
      op: operation,
      model: model_name,
      id: record_id,
      attrs: attrs,
      valid: errors.empty?,
      errors: errors
    }
  end

  def validate_case_transition!(new_status, errors)
    current = @case.status
    allowed = VALID_CASE_TRANSITIONS[current] || []
    unless allowed.include?(new_status.to_s)
      errors << "Invalid transition: #{current} → #{new_status}. Allowed: #{allowed.join(', ')}"
    end
  end

  def validate_record_ownership!(klass, model_name, record_id, errors)
    if model_name == "Case"
      unless record_id == @case.id
        errors << "Cannot update Case #{record_id} — current case is #{@case.id}"
      end
    else
      record = klass.find_by(id: record_id)
      if record.nil?
        errors << "#{model_name} ##{record_id} not found"
      elsif record.respond_to?(:case_id) && record.case_id != @case.id
        errors << "#{model_name} ##{record_id} does not belong to case #{@case.id}"
      end
    end
  end

  def validate_create_linkage!(model_name, attrs, errors)
    case model_name
    when "Case"
      errors << "Cannot create new Case records"
    when "Correspondence"
      # Correspondence links to Action, not Case directly — verify the action belongs to this case
      if attrs["action_id"]
        action = Action.find_by(id: attrs["action_id"])
        unless action&.case_id == @case.id
          errors << "Action ##{attrs['action_id']} does not belong to case #{@case.id}"
        end
      end
    when "EvidenceRequestItem"
      # Links to EvidenceRequest — verify it belongs to this case
      if attrs["evidence_request_id"]
        er = EvidenceRequest.find_by(id: attrs["evidence_request_id"])
        unless er&.case_id == @case.id
          errors << "EvidenceRequest ##{attrs['evidence_request_id']} does not belong to case #{@case.id}"
        end
      end
    else
      # Models with direct case_id
      if attrs["case_id"] && attrs["case_id"].to_i != @case.id
        errors << "case_id must be #{@case.id}, got #{attrs['case_id']}"
      end
    end
  end

  # ── Application ────────────────────────────────────────────

  def apply_operation!(op)
    klass = ALLOWED_MODELS[op[:model]]
    raise ValidationError, "Cannot apply invalid operation" unless op[:valid]

    case op[:op]
    when "update"
      record = op[:model] == "Case" ? @case : klass.find(op[:id])
      record.skip_evaluation = true if record.is_a?(Case)
      record.update!(op[:attrs])
    when "create"
      attrs = op[:attrs].dup
      # Auto-set case_id for models that need it
      if klass.column_names.include?("case_id") && !attrs.key?("case_id")
        attrs["case_id"] = @case.id
      end
      klass.create!(attrs)
    end
  end

  # ── Audit Logging ──────────────────────────────────────────

  def log_evaluation!(raw_response, operations, metadata)
    CaseTypeGenerationLog.create!(
      case_type_config: @case.case_type_config,
      step: 99, # dedicated step for rules engine evaluations
      step_name: "rules_engine_evaluation",
      input_text: serialize_case.to_json,
      output_text: {
        raw_response: raw_response,
        operations: operations,
        case_id: @case.id,
        case_reference: @case.reference
      }.to_json,
      model_used: metadata[:model],
      tokens_used: metadata[:tokens_used]
    )
  rescue => e
    Rails.logger.error("CaseRulesEngine: Failed to log evaluation: #{e.message}")
  end
end
