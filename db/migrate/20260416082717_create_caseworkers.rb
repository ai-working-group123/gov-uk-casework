class CreateCaseworkers < ActiveRecord::Migration[8.1]
  def change
    create_table :caseworkers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.integer :role, default: 0
      t.references :team, null: false, foreign_key: true
      t.integer :capacity, default: 15

      t.timestamps
    end
    add_index :caseworkers, :email, unique: true
  end
end
