class CreateCaseTypeConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :case_type_configs do |t|
      t.string  :name, null: false
      t.string  :slug, null: false
      t.text    :description
      t.string  :organisation
      t.integer :status, default: 0
      t.integer :default_sla_days
      t.text    :decision_tree_md, null: false
      t.text    :state_transitions_md, null: false
      t.text    :evidence_requirements_md
      t.text    :correspondence_templates_md
      t.text    :risk_scoring_md
      t.json    :source_metadata, default: {}
      t.references :created_by, foreign_key: { to_table: :caseworkers }
      t.timestamps
    end
    add_index :case_type_configs, :slug, unique: true
  end
end
