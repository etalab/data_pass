class HubEESingleSubscriptionBridge < HubEEBaseBridge
  def on_approve
    organization_hubee_payload = find_or_create_organization

    create_and_store_subscription(organization_hubee_payload)
  end

  private

  def create_and_store_subscription(organization_hubee_payload)
    subscription_hubee_payload = hubee_api_client.create_subscription(subscription_body(organization_hubee_payload, self.class::PROCESS_CODE))
    authorization_request.update!(external_provider_id: subscription_hubee_payload['id'])
  rescue HubEEAPIClient::AlreadyExistsError
    recover_existing_subscription if authorization_request.external_provider_id.blank?
  end

  def recover_existing_subscription
    existing_subscription = find_existing_subscription

    raise "HubEE subscription should exist but was not found during recovery for authorization_request ##{authorization_request.id}" unless existing_subscription

    Sentry.capture_message(
      "HubEE subscription already exists for authorization_request ##{authorization_request.id}",
      level: :warning,
      extra: { subscription_id: existing_subscription[:id] }
    )

    authorization_request.update!(external_provider_id: existing_subscription[:id])
  end

  def find_existing_subscription
    hubee_api_client.find_subscriptions(datapassId: authorization_request.id)
      .find { |subscription| subscription[:processCode] == self.class::PROCESS_CODE }
  end
end
