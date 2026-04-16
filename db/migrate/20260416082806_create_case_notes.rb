class CreateCaseNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :case_notes do |t|
      t.references :case, null: false, foreign_key: true
      t.references :caseworker, foreign_key: true
      t.text :content, null: false
      t.integer :note_type, default: 0
      t.boolean :visible_to_applicant, default: false
      t.string :applicant_message

      t.timestamps
    end
  end
end
