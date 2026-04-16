class Case < ApplicationRecord
  belongs_to :assigned_to, class_name: "Caseworker", optional: true
  has_many :evidences
  has_many :case_notes
  has_many :actions
  has_many :evidence_requests

  enum :case_type, { tier2_work: 0, tier4_student: 1, family_visa: 2, settlement: 3, visitor: 4 }
  enum :status, { submitted: 0, assigned: 1, in_review: 2, awaiting_evidence: 3,
                  ready_for_decision: 4, decided_approved: 5, decided_refused: 6, withdrawn: 7 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  CASE_TYPE_CODES = {
    "tier2_work"   => "T2",
    "tier4_student" => "T4",
    "family_visa"  => "FV",
    "settlement"   => "ST",
    "visitor"      => "VS"
  }.freeze

  REFERENCE_CHARS = ("A".."Z").to_a - %w[I O] + ("2".."9").to_a

  before_validation :generate_reference, on: :create

  scope :overdue, -> { where("sla_deadline < ?", Time.current).where.not(status: %i[decided_approved decided_refused withdrawn]) }
  scope :approaching_sla, -> { where(sla_deadline: Time.current..7.days.from_now).where.not(status: %i[decided_approved decided_refused withdrawn]) }

  private

  def generate_reference
    return if reference.present?

    type_code = CASE_TYPE_CODES[case_type] || "XX"
    loop do
      suffix = Array.new(4) { REFERENCE_CHARS.sample }.join
      self.reference = "HO-#{type_code}-#{suffix}"
      break unless Case.exists?(reference: reference)
    end
  end
end
