class CreateEvidenceRequestItems < ActiveRecord::Migration[8.1]
  def change
    create_table :evidence_request_items do |t|
      t.references :evidence_request, null: false, foreign_key: true
      t.references :evidence, null: false, foreign_key: true
      t.references :policy_reference, foreign_key: true
      t.integer :submission_method, null: false
      t.text :reason, null: false
      t.integer :status, default: 0
      t.string :upload_content_type
      t.integer :upload_file_size
      t.datetime :received_at
      t.text :applicant_note

      t.timestamps
    end
  end
end
