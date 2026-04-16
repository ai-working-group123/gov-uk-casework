class Case < ApplicationRecord
  belongs_to :assigned_to, class_name: "Caseworker", optional: true
  belongs_to :case_type_config, optional: true
  has_many :evidences
  has_many :case_notes
  has_many :actions
  has_many :evidence_requests

  enum :status, { submitted: 0, assigned: 1, in_review: 2, awaiting_evidence: 3,
                  ready_for_decision: 4, decided_approved: 5, decided_refused: 6, withdrawn: 7 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  REFERENCE_CHARS = ("A".."Z").to_a - %w[I O] + ("2".."9").to_a

  before_validation :generate_reference, on: :create

  scope :overdue, -> { where("sla_deadline < ?", Time.current).where.not(status: %i[decided_approved decided_refused withdrawn]) }
  scope :approaching_sla, -> { where(sla_deadline: Time.current..7.days.from_now).where.not(status: %i[decided_approved decided_refused withdrawn]) }

  attr_accessor :skip_evaluation

  after_commit :enqueue_evaluation, on: [ :create, :update ]

  # Human-readable case type label — from config name if present, otherwise generic
  def case_type_label
    case_type_config&.name || "Application"
  end

  private

  def enqueue_evaluation
    return if skip_evaluation
    return if status.in?(%w[decided_approved decided_refused withdrawn])

    update_column(:evaluation_in_progress, true)
    CaseEvaluationJob.perform_later(id)
  end

  def generate_reference
    return if reference.present?

    # Derive type code from case_type_config slug (first 2 chars uppercased)
    type_code = case_type_config&.slug&.upcase&.slice(0, 2) || "XX"
    loop do
      suffix = Array.new(4) { REFERENCE_CHARS.sample }.join
      self.reference = "HO-#{type_code}-#{suffix}"
      break unless Case.exists?(reference: reference)
    end
  end
end
