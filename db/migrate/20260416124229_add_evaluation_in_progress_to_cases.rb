class AddEvaluationInProgressToCases < ActiveRecord::Migration[8.1]
  def change
    add_column :cases, :evaluation_in_progress, :boolean, default: false, null: false
  end
end
