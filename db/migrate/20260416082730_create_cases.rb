class CreateCases < ActiveRecord::Migration[8.1]
  def change
    create_table :cases do |t|
      t.string :reference, null: false
      t.string :applicant_name, null: false
      t.string :applicant_email
      t.string :nationality
      t.integer :case_type, null: false
      t.integer :status, default: 0
      t.integer :priority, default: 1
      t.integer :risk_score, default: 0
      t.references :assigned_to, foreign_key: { to_table: :caseworkers }
      t.datetime :submitted_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :assigned_at
      t.datetime :sla_deadline, null: false
      t.datetime :decided_at

      t.timestamps
    end
    add_index :cases, :reference, unique: true
  end
end
