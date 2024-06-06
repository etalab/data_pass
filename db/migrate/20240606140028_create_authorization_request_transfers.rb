class CreateAuthorizationRequestTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :authorization_request_transfers do |t|
      t.references :authorization_request, null: false, foreign_key: true
      t.references :from, null: false, foreign_key: { to_table: :users }
      t.references :to, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
