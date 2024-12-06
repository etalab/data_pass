class AddRawAttributesFromV1ToAuthorizationRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_requests, :raw_attributes_from_v1, :text
  end
end
