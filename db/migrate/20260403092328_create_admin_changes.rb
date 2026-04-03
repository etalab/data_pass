class CreateAdminChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_changes do |t|
      t.references :authorization_request, null: false, foreign_key: true
      t.text :public_reason, null: false
      t.text :private_reason
      t.json :diff, default: {}

      t.timestamps
    end
  end
end
