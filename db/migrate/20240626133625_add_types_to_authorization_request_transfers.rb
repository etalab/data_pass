class AddTypesToAuthorizationRequestTransfers < ActiveRecord::Migration[7.1]
  def up
    add_column :authorization_request_transfers, :from_type, :string
    add_column :authorization_request_transfers, :to_type, :string

    AuthorizationRequestTransfer.update_all(from_type: 'User', to_type: 'User')

    change_column_null :authorization_request_transfers, :from_type, false
    change_column_null :authorization_request_transfers, :to_type, false


    remove_foreign_key :authorization_request_transfers, column: :from_id
    remove_foreign_key :authorization_request_transfers, column: :to_id
  end

  def down
    remove_column :authorization_request_transfers, :from_type
    remove_column :authorization_request_transfers, :to_type

    add_foreign_key :authorization_request_transfers, :users, column: :from_id
    add_foreign_key :authorization_request_transfers, :users, column: :to_id
  end
end
