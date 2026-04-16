class CreateEvidenceRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :evidence_requests do |t|
      t.references :case, null: false, foreign_key: true
      t.references :requested_by, null: false, foreign_key: { to_table: :caseworkers }
      t.integer :status, default: 0
      t.datetime :deadline, null: false
      t.integer :notify_via, default: 0
      t.text :cover_message
      t.datetime :sent_at
      t.datetime :reminder_sent_at

      t.timestamps
    end
  end
end
