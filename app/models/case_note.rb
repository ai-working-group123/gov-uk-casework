class CaseNote < ApplicationRecord
  belongs_to :case
  belongs_to :caseworker, optional: true
  enum :note_type, { manual: 0, system: 1, decision: 2, evidence: 3 }
end
