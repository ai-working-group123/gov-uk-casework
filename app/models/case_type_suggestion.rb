class CaseTypeSuggestion < ApplicationRecord
  belongs_to :case_type_config
  belongs_to :resolved_by, class_name: "Caseworker", optional: true

  enum :status, { suggested: 0, accepted: 1, rejected: 2, deferred: 3 }
  enum :priority, { low: 0, medium: 1, high: 2 }
end
