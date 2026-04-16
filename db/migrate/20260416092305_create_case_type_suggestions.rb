class CreateCaseTypeSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :case_type_suggestions do |t|
      t.references :case_type_config, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description, null: false
      t.string  :category
      t.integer :priority, default: 1
      t.text    :impact_description
      t.string  :standard_reference
      t.integer :status, default: 0
      t.references :resolved_by, foreign_key: { to_table: :caseworkers }
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
