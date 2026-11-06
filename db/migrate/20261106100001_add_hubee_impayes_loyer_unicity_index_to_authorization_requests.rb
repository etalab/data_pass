class AddHubEEImpayesLoyerUnicityIndexToAuthorizationRequests < ActiveRecord::Migration[8.1]
  def change
    add_index :authorization_requests, %i[type organization_id],
      unique: true,
      where: "type = 'AuthorizationRequest::HubEEImpayesLoyer' AND state != 'archived'",
      name: 'index_authorization_requests_unicity_hubee_impayes_loyer'
  end
end
