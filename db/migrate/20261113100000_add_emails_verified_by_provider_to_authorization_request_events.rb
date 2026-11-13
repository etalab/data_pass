class AddEmailsVerifiedByProviderToAuthorizationRequestEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_request_events, :emails_verified_by_provider, :boolean, default: false, null: false
  end
end
