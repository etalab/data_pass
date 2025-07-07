class CreateImpersonations < ActiveRecord::Migration[8.0]
  def change
    create_table :impersonations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.text :reason, null: false
      t.datetime :finished_at

      t.timestamps
    end

    create_table :impersonation_actions do |t|
      t.references :impersonation, null: false, foreign_key: true
      t.string :action, null: false
      t.string :model_type, null: false
      t.integer :model_id, null: false
      t.string :controller, null: false

      t.timestamps
    end
  end
end
