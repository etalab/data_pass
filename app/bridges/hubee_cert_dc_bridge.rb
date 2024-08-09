class HubEECertDCBridge < ApplicationBridge
  def on_approve
    organization_hubee_payload = find_or_create_organization

    create_and_store_subscription(organization_hubee_payload)
  end

  private

  def find_or_create_organization
    hubee_api_client.get_organization(organization.siret, organization.code_commune)
  rescue Faraday::ResourceNotFound
    hubee_api_client.create_organization(organization_create_payload)
  end

  def create_and_store_subscription(organization_hubee_payload)
    subscription_hubee_payload = hubee_api_client.create_subscription(subscription_body(organization_hubee_payload, process_code))
    authorization_request.update!(linked_token_manager_id: subscription_hubee_payload['id'])
  end

  def organization_create_payload
    {
      type: 'SI',
      companyRegister: organization.siret,
      branchCode: organization.code_commune,
      name: organization.denomination,
      code: organization.sigle_unite_legale,
      country: 'France',
      postalCode: organization.code_postal,
      territory: organization.libele_commune,
      email: authorization_request.administrateur_metier_email,
      phoneNumber: authorization_request.administrateur_metier_phone_number.gsub(/[ .-]/, ''),
      status: 'Actif'
    }
  end

  def subscription_body(organization_hubee_payload, process_code)
    {
      datapassId: authorization_request.id,
      processCode: process_code,
      subscriber: {
        type: organization_hubee_payload[:type],
        companyRegister: organization_hubee_payload[:companyRegister],
        branchCode: organization_hubee_payload[:branchCode],
      },
      notificationFrequency: 'unitaire',
      validateDateTime: authorization_request.last_validated_at.iso8601,
      updateDateTime: authorization_request[:updated_at].iso8601,
      status: 'Inactif',
      email: authorization_request.administrateur_metier_email,
      localAdministrator: {
        email: authorization_request.administrateur_metier_email,
      }
    }
  end

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end

  def process_code
    'CERTDC'
  end

  def organization
    authorization_request.organization
  end
end
