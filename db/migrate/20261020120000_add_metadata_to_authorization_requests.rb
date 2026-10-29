class AddMetadataToAuthorizationRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :authorization_requests, :metadata, :jsonb, default: {}, null: false
  end
end
