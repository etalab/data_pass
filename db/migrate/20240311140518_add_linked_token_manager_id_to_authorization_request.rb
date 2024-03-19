class AddLinkedTokenManagerIdToAuthorizationRequest < ActiveRecord::Migration[7.1]
  def change
    add_column :authorization_requests, :linked_token_manager_id, :string
  end
end
