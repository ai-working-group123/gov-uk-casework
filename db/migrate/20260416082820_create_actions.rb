class CreateActions < ActiveRecord::Migration[8.1]
  def change
    create_table :actions do |t|
      t.references :case, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :action_type, null: false
      t.integer :status, default: 0
      t.datetime :due_date
      t.datetime :completed_at
      t.string :blocked_by
      t.references :policy_reference, foreign_key: true
      t.text :caseworker_guidance

      t.timestamps
    end
  end
end
