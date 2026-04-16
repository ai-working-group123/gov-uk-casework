
class CaseTypeConfigsController < ApplicationController
  layout "admin"

  before_action :set_case_type_config, only: [
    :show, :edit, :update, :questions, :answer, :review, :submit_review,
    :suggestions, :apply_suggestions, :finalise, :publish,
    :processing, :generate
  ]

  def index
    @case_type_configs = CaseTypeConfig.order(created_at: :desc)
  end

  def new
    @case_type_config = CaseTypeConfig.new
  end

  # GET /admin/case_type_configs/:id/edit
  def edit
  end

  # PATCH /admin/case_type_configs/:id
  # Re-analyses with updated description + URLs
  def update
    @case_type_config.update!(
      description: params[:description],
      source_metadata: {
        source_type: params[:urls].present? ? "url" : "description",
        urls: Array(params[:urls]).reject(&:blank?),
        description: params[:description],
        submitted_at: Time.current.iso8601
      }
    )

    result = generator.scrape_and_analyse!(
      description: params[:description],
      urls: Array(params[:urls]).reject(&:blank?)
    )

    @case_type_config.case_type_generation_logs.create!(
      step: 2,
      step_name: "re_analyse",
      input_text: params[:description],
      output_text: result[:analysis].to_json,
      model_used: result.dig(:metadata, :model),
      tokens_used: result.dig(:metadata, :tokens_used),
      confidence_score: 0.5
    )

    @case_type_config.update!(
      analysis: result[:analysis],
      clarifying_questions: result[:questions]
    )

    redirect_to questions_case_type_config_path(@case_type_config)
  end

  # POST /admin/case_type_configs
  # Receives description + URLs, kicks off scrape & analyse
  def create
    @case_type_config = CaseTypeConfig.new(
      name: "Untitled — Generating...",
      slug: "draft-#{SecureRandom.hex(6)}",
      description: params[:description],
      decision_tree_md: "",
      state_transitions_md: "",
      source_metadata: {
        source_type: params[:urls].present? ? "url" : "description",
        urls: Array(params[:urls]).reject(&:blank?),
        description: params[:description],
        submitted_at: Time.current.iso8601
      },
      status: :draft
    )

    if @case_type_config.save
      result = generator.scrape_and_analyse!(
        description: params[:description],
        urls: Array(params[:urls]).reject(&:blank?)
      )

      @case_type_config.case_type_generation_logs.create!(
        step: 2,
        step_name: "analyse",
        input_text: params[:description],
        output_text: result[:analysis].to_json,
        model_used: result.dig(:metadata, :model),
        tokens_used: result.dig(:metadata, :tokens_used),
        confidence_score: 0.5
      )

      @case_type_config.update!(
        analysis: result[:analysis],
        clarifying_questions: result[:questions]
      )

      redirect_to questions_case_type_config_path(@case_type_config)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/case_type_configs/:id/questions
  def questions
    @questions = @case_type_config.clarifying_questions.map(&:symbolize_keys)
    @saved_answers = (@case_type_config.clarifying_answers || {}).transform_keys(&:to_s)
  end

  # POST /admin/case_type_configs/:id/answer
  # Receives answers to clarifying questions, triggers generation
  def answer
    analysis_json = @case_type_config.analysis

    # Build answers text block from form params
    answers = params[:answers]&.to_unsafe_h || {}
    answers_text = answers.map { |qid, answer_data|
      question_text = answer_data[:question]
      response = if answer_data[:skip] == "1"
        "I don't know — use your best judgement"
      elsif answer_data[:custom].present?
        answer_data[:custom]
      else
        answer_data[:selected]
      end
      "Q: #{question_text}\nA: #{response}"
    }.join("\n\n")

    @case_type_config.update!(clarifying_answers: answers.to_h)

    @case_type_config.case_type_generation_logs.create!(
      step: 2,
      step_name: "clarifying_answers",
      input_text: answers_text,
      output_text: "",
      confidence_score: 0.8
    )

    result = generator.generate_config!(
      analysis_json: analysis_json,
      answers_text: answers_text
    )

    # Ensure slug is unique — the LLM may return a duplicate
    slug = result[:slug]
    if CaseTypeConfig.where.not(id: @case_type_config.id).exists?(slug: slug)
      slug = "#{slug}-#{@case_type_config.id}"
    end

    @case_type_config.update!(
      name: result[:name],
      slug: slug,
      description: result[:description],
      default_sla_days: result[:default_sla_days],
      decision_tree_md: result[:decision_tree_md],
      state_transitions_md: result[:state_transitions_md],
      evidence_requirements_md: result[:evidence_requirements_md],
      risk_scoring_md: result[:risk_scoring_md],
      correspondence_templates_md: result[:correspondence_templates_md]
    )

    @case_type_config.case_type_generation_logs.create!(
      step: 3,
      step_name: "generate",
      input_text: answers_text,
      output_text: result.except(:metadata).to_json,
      model_used: result.dig(:metadata, :model),
      tokens_used: result.dig(:metadata, :tokens_used),
      confidence_score: 0.9
    )

    redirect_to review_case_type_config_path(@case_type_config)
  end

  # GET /admin/case_type_configs/:id
  # Redirects to the latest step the user has reached
  def show
    step = @case_type_config.current_step

    redirect_path = case step
    when 5 then finalise_case_type_config_path(@case_type_config)
    when 4 then suggestions_case_type_config_path(@case_type_config)
    when 3 then review_case_type_config_path(@case_type_config)
    when 2 then questions_case_type_config_path(@case_type_config)
    else edit_case_type_config_path(@case_type_config)
    end

    redirect_to redirect_path
  end

  # GET /admin/case_type_configs/:id/review
  def review
  end

  # POST /admin/case_type_configs/:id/submit_review
  # Saves edited markdown sections, then kicks off improvement suggestions
  def submit_review
    @case_type_config.update!(
      decision_tree_md: params[:decision_tree_md],
      state_transitions_md: params[:state_transitions_md],
      evidence_requirements_md: params[:evidence_requirements_md],
      risk_scoring_md: params[:risk_scoring_md],
      correspondence_templates_md: params[:correspondence_templates_md]
    )

    config_snapshot = @case_type_config.attributes.slice(
      "name", "description",
      "decision_tree_md", "state_transitions_md", "evidence_requirements_md",
      "risk_scoring_md", "correspondence_templates_md"
    )

    result = generator.suggest_improvements!(config_snapshot: config_snapshot)

    result[:suggestions].each do |suggestion|
      @case_type_config.case_type_suggestions.create!(
        title: suggestion[:title],
        description: suggestion[:description],
        category: suggestion[:category],
        priority: suggestion[:priority],
        impact_description: suggestion[:impact_description],
        standard_reference: suggestion[:standard_reference]
      )
    end

    @case_type_config.case_type_generation_logs.create!(
      step: 4,
      step_name: "suggest_improvements",
      input_text: config_snapshot.to_json,
      output_text: result.except(:metadata).to_json,
      model_used: result.dig(:metadata, :model),
      tokens_used: result.dig(:metadata, :tokens_used),
      confidence_score: 0.85
    )

    redirect_to suggestions_case_type_config_path(@case_type_config)
  end

  # GET /admin/case_type_configs/:id/suggestions
  def suggestions
    @suggestions = @case_type_config.case_type_suggestions.order(priority: :desc)
  end

  # POST /admin/case_type_configs/:id/apply_suggestions
  # Processes accepted/rejected suggestions and applies them via LLM
  def apply_suggestions
    accepted_ids = []
    comments = {}
    suggestion_params = params[:suggestions]&.to_unsafe_h || {}

    @case_type_config.case_type_suggestions.each do |suggestion|
      data = suggestion_params[suggestion.id.to_s]
      if data && data["accepted"] == "1"
        suggestion.update!(status: :accepted)
        accepted_ids << suggestion.id
        comments[suggestion.id.to_s] = data["comment"] if data["comment"].present?
      else
        suggestion.update!(status: :rejected)
      end
    end

    if accepted_ids.any?
      accepted = @case_type_config.case_type_suggestions.where(id: accepted_ids)

      config_snapshot = @case_type_config.attributes.slice(
        "decision_tree_md", "state_transitions_md", "evidence_requirements_md",
        "risk_scoring_md", "correspondence_templates_md"
      )

      result = generator.apply_suggestions!(
        config_snapshot: config_snapshot,
        accepted_suggestions: accepted.map { |s| { title: s.title, description: s.description, category: s.category } },
        comments: comments
      )

      # Apply any updated markdown sections returned by the LLM
      updatable = result.slice(:decision_tree_md, :state_transitions_md,
        :evidence_requirements_md, :risk_scoring_md, :correspondence_templates_md)
      @case_type_config.update!(updatable) if updatable.any?

      @case_type_config.case_type_generation_logs.create!(
        step: 5,
        step_name: "apply_suggestions",
        input_text: accepted.map(&:title).join(", "),
        output_text: result.except(:metadata).to_json,
        model_used: result.dig(:metadata, :model),
        tokens_used: result.dig(:metadata, :tokens_used),
        confidence_score: 0.9
      )
    end

    redirect_to finalise_case_type_config_path(@case_type_config)
  end

  # GET /admin/case_type_configs/:id/finalise
  def finalise
  end

  # POST /admin/case_type_configs/:id/publish
  def publish
    @case_type_config.update!(status: :published)
    redirect_to case_type_configs_path, notice: "\"#{@case_type_config.name}\" has been published."
  end

  # GET /admin/case_type_configs/:id/processing
  def processing
  end

  # POST /admin/case_type_configs/:id/generate
  def generate
  end

  private

  def set_case_type_config
    @case_type_config = CaseTypeConfig.find(params[:id])
  end

  def generator
    @generator ||= LlmService.new
  end

end
