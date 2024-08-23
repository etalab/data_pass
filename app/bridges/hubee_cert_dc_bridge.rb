class HubEECertDCBridge < HubEEBaseBridge
  def on_approve
    organization_hubee_payload = find_or_create_organization

    create_and_store_subscription(organization_hubee_payload, 'CERTDC')
  end

  private

  def create_and_store_subscription(organization_hubee_payload, process_code)
    subscription_hubee_payload = hubee_api_client.create_subscription(subscription_body(organization_hubee_payload, process_code))
    authorization_request.update!(linked_token_manager_id: subscription_hubee_payload['id'])
  end
end
