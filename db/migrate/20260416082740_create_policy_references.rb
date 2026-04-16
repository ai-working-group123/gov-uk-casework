class CreatePolicyReferences < ActiveRecord::Migration[8.1]
  def change
    create_table :policy_references do |t|
      t.string :code, null: false
      t.string :parent_code
      t.string :title, null: false
      t.string :policy_area, null: false
      t.string :case_types, null: false
      t.text :summary, null: false
      t.text :criteria, null: false
      t.string :govuk_url
      t.string :legislation_url
      t.string :internal_guidance_url
      t.text :applicant_summary
      t.string :applicant_url

      t.timestamps
    end
    add_index :policy_references, :code, unique: true
  end
end
