class CaseTypeConfig < ApplicationRecord
  belongs_to :created_by, class_name: "Caseworker", optional: true
  has_many :cases, dependent: :restrict_with_error
  has_many :case_type_generation_logs, dependent: :destroy
  has_many :case_type_suggestions, dependent: :destroy

  enum :status, { draft: 0, published: 1, archived: 2 }

  # Returns the furthest step (1-5) this config has reached.
  def current_step
    if published?
      5
    elsif case_type_suggestions.where(status: :suggested).none? && case_type_suggestions.any?
      5 # all suggestions processed → finalise
    elsif case_type_suggestions.any?
      4 # suggestions exist but not all processed
    elsif decision_tree_md.present?
      3 # markdown generated → review
    else
      1
    end
  end
end
