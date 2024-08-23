class HubEECertDCBridge < HubEEBaseBridge
  def on_approve
    organization_hubee_payload = find_or_create_organization

    create_and_store_subscription(organization_hubee_payload, 'CERTDC')
  end
end
