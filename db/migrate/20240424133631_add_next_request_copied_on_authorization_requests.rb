class AddNextRequestCopiedOnAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :authorization_requests, :next_request_copied, foreign_key: { to_table: :authorization_requests }
  end
end
