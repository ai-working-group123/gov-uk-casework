class CaseEvaluationJob < ApplicationJob
  queue_as :default

  retry_on LlmService::RateLimitError, wait: :polynomially_longer, attempts: 3
  retry_on LlmService::TimeoutError, wait: 30.seconds, attempts: 2
  discard_on LlmService::ParseError

  def perform(case_id)
    kase = Case.includes(:case_type_config, :evidences, :actions, :case_notes, :evidence_requests).find_by(id: case_id)
    return unless kase
    return clear_flag(kase) if kase.case_type_config.nil?
    return clear_flag(kase) if kase.status.in?(%w[decided_approved decided_refused withdrawn])

    engine = CaseRulesEngine.new(kase)
    engine.evaluate_and_apply!
  rescue LlmService::Error => e
    Rails.logger.error("CaseEvaluationJob: Failed for case #{case_id}: #{e.message}")
    raise
  ensure
    if kase
      kase.update_column(:evaluation_in_progress, false)
      broadcast_banner_removal(kase)
    end
  end

  private

  def clear_flag(kase)
    kase.update_column(:evaluation_in_progress, false)
    broadcast_banner_removal(kase)
  end

  def broadcast_banner_removal(kase)
    Turbo::StreamsChannel.broadcast_replace_to(
      kase,
      target: "case_evaluation_banner",
      html: '<turbo-frame id="case_evaluation_banner"></turbo-frame>'
    )
  end
end
