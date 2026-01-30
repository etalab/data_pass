class AddParentAuthorizationIdToAuthorizations < ActiveRecord::Migration[8.1]
  def change
    add_column :authorizations, :parent_authorization_id, :bigint
    add_index :authorizations, :parent_authorization_id
    add_foreign_key :authorizations, :authorizations, column: :parent_authorization_id
  end
end
