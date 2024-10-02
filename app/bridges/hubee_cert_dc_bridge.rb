class HubEECertDCBridge < HubEEBaseBridge
  def on_approve
    organization_hubee_payload = find_or_create_organization

    create_and_store_subscription(organization_hubee_payload, 'CERTDC')
  end

  private

  def create_and_store_subscription(organization_hubee_payload, process_code)
    subscription_hubee_payload = hubee_api_client.create_subscription(subscription_body(organization_hubee_payload, process_code))
    authorization_request.update!(external_provider_id: subscription_hubee_payload['id'])
  rescue HubEEAPIClient::AlreadyExistsError
    raise unless authorization_request.external_provider_id.present? || authorization_request_reopening?
  end

  def authorization_request_reopening?
    authorization_request.last_validated_at.present?
  end
end
