class Action < ApplicationRecord
  belongs_to :case
  belongs_to :policy_reference, optional: true
  has_many :correspondences
  enum :action_type, { chase_evidence: 0, review_documents: 1, make_decision: 2,
                       send_correspondence: 3, escalate: 4, schedule_interview: 5 }
  enum :status, { pending: 0, in_progress: 1, completed: 2, blocked: 3, cancelled: 4 }
end
