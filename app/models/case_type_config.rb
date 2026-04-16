class CaseTypeConfig < ApplicationRecord
  belongs_to :created_by, class_name: "Caseworker", optional: true
  has_many :case_type_generation_logs, dependent: :destroy
  has_many :case_type_suggestions, dependent: :destroy

  enum :status, { draft: 0, published: 1, archived: 2 }
end
