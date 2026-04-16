class AddPipelineStateToCase < ActiveRecord::Migration[8.1]
  def change
    add_column :case_type_configs, :analysis, :json, default: {}
    add_column :case_type_configs, :clarifying_questions, :json, default: []
    add_column :case_type_configs, :clarifying_answers, :json, default: {}
  end
end
