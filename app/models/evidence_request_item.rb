class EvidenceRequestItem < ApplicationRecord
  belongs_to :evidence_request
  belongs_to :evidence
  belongs_to :policy_reference, optional: true

  enum :submission_method, { digital: 0, physical: 1, either: 2 }
  enum :status, { pending: 0, received: 1, accepted: 2, rejected: 3 }

  def allows_upload?
    digital? || either?
  end

  def requires_post?
    physical? || either?
  end
end
