class AddAPIApplicationNameToAuthorizationRequestEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :authorization_request_events, :api_application_name, :string
  end
end
