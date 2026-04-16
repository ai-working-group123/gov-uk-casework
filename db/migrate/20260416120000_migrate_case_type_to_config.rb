class MigrateCaseTypeToConfig < ActiveRecord::Migration[8.1]
  def change
    # Add foreign key to case_type_configs
    add_reference :cases, :case_type_config, foreign_key: true

    # Remove the old enum column
    remove_column :cases, :case_type, :integer
  end
end
