class AddCaseDataToCases < ActiveRecord::Migration[8.1]
  def change
    add_column :cases, :case_data, :json, default: {}
  end
end
