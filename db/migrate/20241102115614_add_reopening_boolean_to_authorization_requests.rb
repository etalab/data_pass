class AddReopeningBooleanToAuthorizationRequests < ActiveRecord::Migration[7.2]
  def up
    add_column :authorization_requests, :reopening, :boolean, default: false

    AuthorizationRequest.where(
      "state not in ('validated', 'revoked') and reopened_at is not null"
    ).update_all(reopening: true)
  end

  def down
    remove_column :authorization_requests, :reopening
  end
end
