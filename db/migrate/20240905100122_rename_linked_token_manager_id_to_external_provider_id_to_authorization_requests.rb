class RenameLinkedTokenManagerIdToExternalProviderIdToAuthorizationRequests < ActiveRecord::Migration[7.2]
  def change
    rename_column :authorization_requests, :linked_token_manager_id, :external_provider_id
  end
end
