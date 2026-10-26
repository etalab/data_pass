class AddNotificationsDisabledToAuthorizationRequestEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_request_events, :notifications_disabled, :boolean, default: false, null: false
  end
end
