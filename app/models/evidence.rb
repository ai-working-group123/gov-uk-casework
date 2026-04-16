class Evidence < ApplicationRecord
  belongs_to :case
  belongs_to :policy_reference, optional: true
  enum :evidence_type, { passport: 0, english_language: 1, tb_certificate: 2, bank_statements: 3,
                         sponsorship_certificate: 4, biometrics: 5, employer_letter: 6,
                         accommodation_proof: 7, relationship_evidence: 8, police_clearance: 9 }
  enum :status, { not_received: 0, received: 1, under_review: 2, accepted: 3, rejected: 4 }
end
