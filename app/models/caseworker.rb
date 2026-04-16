class Caseworker < ApplicationRecord
  belongs_to :team
  has_many :cases, foreign_key: :assigned_to_id
  has_many :case_notes
  enum :role, { caseworker: 0, senior_caseworker: 1, team_leader: 2 }
end
