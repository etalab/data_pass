class RemoveNullConstraintOnDataAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    change_column_null :authorization_requests, :data, true
  end
end
