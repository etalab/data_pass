class AddFormUidToAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :authorization_requests, :form_uid, :string, null: false
  end
end
