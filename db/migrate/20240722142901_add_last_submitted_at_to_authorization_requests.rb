class AddLastSubmittedAtToAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :authorization_requests, :last_submitted_at, :datetime
  end
end
