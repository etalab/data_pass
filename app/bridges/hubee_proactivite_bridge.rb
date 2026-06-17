class HubEEProactiviteBridge < HubEEBaseBridge
  PROCESS_CODE = 'ProactiviteCnousBoursiers'.freeze

  def on_approve
    create_and_store_subscription(find_or_create_organization, PROCESS_CODE)
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

  def local_administrator_data
    {
      email: authorization_request.contact_technique_email,
      firstName: authorization_request.contact_technique_given_name,
      lastName: authorization_request.contact_technique_family_name,
      function: authorization_request.contact_technique_job_title,
      phoneNumber: authorization_request.contact_technique_phone_number.gsub(/[\s.-]/, ''),
    }
  end
end
