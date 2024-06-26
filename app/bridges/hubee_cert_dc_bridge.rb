class HubEECertDCBridge < ApplicationBridge
  def perform
    hubee_organization = hubee_api_client.get_organization(authorization_request.organization.siret)

    subscription_payload = hubee_api_client.create_subscription(hubee_organization, 'CERTDC')

    authorization_request.update!(linked_token_manager_id: subscription_payload['id'])
  end

  private

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end
end
