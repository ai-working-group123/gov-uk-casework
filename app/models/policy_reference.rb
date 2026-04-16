class PolicyReference < ApplicationRecord
  has_many :evidences
  has_many :actions
  has_many :correspondences
  has_many :evidence_request_items
end
