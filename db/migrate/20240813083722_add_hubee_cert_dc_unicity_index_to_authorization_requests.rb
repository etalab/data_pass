class AddHubEECertDCUnicityIndexToAuthorizationRequests < ActiveRecord::Migration[7.2]
  def change
    add_index :authorization_requests, [:type, :organization_id], unique: true, where: "type = 'AuthorizationRequest::HubEECertDC' AND state != 'archived'"
  end
end
