class CreateImpersonations < ActiveRecord::Migration[8.0]
  def change
    create_table :impersonations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.text :reason

      t.timestamps
    end
  end
end
