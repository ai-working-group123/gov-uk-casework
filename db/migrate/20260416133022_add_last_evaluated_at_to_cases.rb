class AddLastEvaluatedAtToCases < ActiveRecord::Migration[8.1]
  def change
    add_column :cases, :last_evaluated_at, :datetime
  end
end
