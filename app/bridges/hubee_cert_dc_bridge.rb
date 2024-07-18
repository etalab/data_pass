class HubEECertDCBridge < ApplicationBridge
  def perform
    organization = find_or_create_organization(authorization_request)

    create_and_store_subscription(authorization_request, organization)
  end

  private

  def find_or_create_organization(authorization_request)
    hubee_api_client.get_organization(organization.siret, organization.code_commune)
  rescue Faraday::ResourceNotFound
    organization_payload = organization_body(organization, authorization_request)
    hubee_api_client.create_organization(organization_payload)
  end

  def create_and_store_subscription(authorization_request, organization)
    subscription_payload = hubee_api_client.create_subscription(subscription_body(authorization_request, organization, process_code))
    authorization_request.update!(linked_token_manager_id: subscription_payload['id'])
  end

  def organization_body(organization, authorization_request)
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

  def subscription_body(authorization_request, organization, process_code)
    {
      datapassId: authorization_request.id,
      processCode: process_code,
      subscriber: {
        type: organization[:type],
        companyRegister: organization[:companyRegister],
        branchCode: organization[:branchCode],
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
