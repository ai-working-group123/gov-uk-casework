class CreateCaseTypeGenerationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :case_type_generation_logs do |t|
      t.references :case_type_config, null: false, foreign_key: true
      t.integer :step, null: false
      t.string  :step_name, null: false
      t.text    :input_text
      t.text    :output_text
      t.string  :model_used
      t.integer :tokens_used
      t.float   :confidence_score
      t.timestamps
    end
  end
end
