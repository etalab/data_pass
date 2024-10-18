class HubEEBaseBridge < ApplicationBridge
  protected

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
      localAdministrator: local_administrator_data
    }
  end

  def local_administrator_data
    {
      email: authorization_request.administrateur_metier_email,
      firstName: authorization_request.administrateur_metier_given_name,
      lastName: authorization_request.administrateur_metier_family_name,
      function: authorization_request.administrateur_metier_job_title,
      phoneNumber: authorization_request.administrateur_metier_phone_number.gsub(/[\s\.\-]/, ''),
    }
  end

  def find_or_create_organization
    hubee_api_client.get_organization(organization.siret, organization.code_commune)
  rescue Faraday::ResourceNotFound
    hubee_api_client.create_organization(organization_create_payload)
  end

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end

  def organization
    authorization_request.organization
  end
end
