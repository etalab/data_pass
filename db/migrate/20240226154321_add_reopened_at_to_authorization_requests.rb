class AddReopenedAtToAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :authorization_requests, :reopened_at, :datetime
  end
end
