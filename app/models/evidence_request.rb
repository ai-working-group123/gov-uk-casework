class EvidenceRequest < ApplicationRecord
  belongs_to :case
  belongs_to :requested_by, class_name: "Caseworker"
  has_many :evidence_request_items, dependent: :destroy
  accepts_nested_attributes_for :evidence_request_items, allow_destroy: true

  enum :status, { draft: 0, sent: 1, partially_fulfilled: 2, fulfilled: 3, expired: 4 }

  NOTIFY_EMAIL  = 1
  NOTIFY_PORTAL = 2
  NOTIFY_SMS    = 4

  def notify_email?  = notify_via & NOTIFY_EMAIL  > 0
  def notify_portal? = notify_via & NOTIFY_PORTAL > 0
  def notify_sms?    = notify_via & NOTIFY_SMS    > 0

  def all_items_received?
    evidence_request_items.all? { |item| item.received? || item.accepted? }
  end
end
