class CreateEvidences < ActiveRecord::Migration[8.1]
  def change
    create_table :evidences do |t|
      t.references :case, null: false, foreign_key: true
      t.integer :evidence_type, null: false
      t.integer :status, default: 0
      t.datetime :received_at
      t.datetime :reviewed_at
      t.text :notes
      t.datetime :required_by
      t.references :policy_reference, foreign_key: true

      t.timestamps
    end
  end
end
