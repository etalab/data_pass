class ChangeAuthorizationRequestIdOnAuthorizations < ActiveRecord::Migration[7.1]
  def up
    rename_column :authorizations, :authorization_request_id, :request_id
  end

  def down
    rename_column :authorizations, :request_id, :authorization_request_id
  end
end
