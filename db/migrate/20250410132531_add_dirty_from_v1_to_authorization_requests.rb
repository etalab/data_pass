class AddDirtyFromV1ToAuthorizationRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_requests, :dirty_from_v1, :boolean, default: false
  end
end
