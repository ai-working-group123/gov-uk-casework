class CreateCorrespondences < ActiveRecord::Migration[8.1]
  def change
    create_table :correspondences do |t|
      t.references :action, null: false, foreign_key: true
      t.integer :channel, default: 0
      t.integer :direction, default: 0
      t.string :subject, null: false
      t.text :body, null: false
      t.references :policy_reference, foreign_key: true
      t.text :policy_explanation
      t.string :guidance_url
      t.datetime :sent_at

      t.timestamps
    end
  end
end
