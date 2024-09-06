class AddPublicIdToAuthorizationRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :authorization_requests, :public_id, :uuid, default: 'gen_random_uuid()'
    add_index :authorization_requests, :public_id
  end
end
