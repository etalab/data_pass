class CreateImpersonationActions < ActiveRecord::Migration[8.0]
  def change
    create_table :impersonation_actions do |t|
      t.references :impersonation, null: false, foreign_key: true
      t.string :action
      t.string :model_type
      t.integer :model_id

      t.timestamps
    end
  end
end
