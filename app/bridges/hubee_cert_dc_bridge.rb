class HubeeCertDCBridge < ApplicationBridge

  def perform
    @authorization_request = @authorization_request.decorate

    administrateur_metier = @authorization_request.contact_data_by_type(:administrateur_metier)
    siret = @authorization_request.organization[:siret]
    updated_at = @authorization_request[:updated_at]
    validated_at = @authorization_request.validated_at
    scopes = @authorization_request.data["scopes"]
    authorization_id = @authorization_request.authorizations.last.id

    linked_token_manager_id = create_enrollment_in_token_manager(
      authorization_id,
      administrateur_metier,
      siret,
      updated_at,
      validated_at,
      scopes
    )
    @authorization_request.update({ linked_token_manager_id: linked_token_manager_id })
  end

  private

  def create_enrollment_in_token_manager(
    id,
    administrateur_metier_data,
    siret,
    updated_at,
    validated_at,
    scopes
  )
    response = ApiSirene.call(siret)

    denomination = response[:denomination]
    sigle = response[:sigle]
    code_postal = response[:code_postal]
    code_commune = response[:code_commune]
    libelle_commune = response[:libelle_commune]

    hubee_configuration = Credentials.get(:hubee)
    api_host = hubee_configuration[:host]
    hubee_auth_url = hubee_configuration[:auth_url]
    client_id = hubee_configuration[:client_id]
    client_secret = hubee_configuration[:client_secret]

    # 1. get token
    token_response = Http.instance.post({
      url: hubee_auth_url,
      body: { grant_type: "client_credentials", scope: "ADMIN" },
      api_key: Base64.strict_encode64("#{client_id}:#{client_secret}"),
      use_basic_auth_method: true,
      tag: "Portail HubEE"
    })

    token = token_response.parse
    access_token = token["access_token"]

    # 2.1 get organization
    begin
      Http.instance.get({
        url: "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}",
        api_key: access_token,
        tag: "Portail HubEE"
      })
    rescue ApplicationController::BadGateway => e
      if e.http_code == 404
        # 2.2 if organization does not exist, create the organization
        Http.instance.post({
          url: "#{api_host}/referential/v1/organizations",
          body: {
            type: "SI",
            companyRegister: siret,
            branchCode: code_commune,
            name: denomination,
            code: sigle,
            country: "France",
            postalCode: code_postal,
            territory: libelle_commune,
            email: administrateur_metier_data[:email],
            phoneNumber: administrateur_metier_data[:phone_number].delete(" ").delete(".").delete("-"),
            status: "Actif"
          },
          api_key: access_token,
          tag: "Portail HubEE"
        })
      else
        raise
      end
    end

    # 3. create subscriptions
    subscription_ids = []
    scopes.each do |scope|
      create_subscription_response = Http.instance.post({
        url: "#{api_host}/referential/v1/subscriptions",
        body: {
          datapassId: id,
          processCode: scope,
          subscriber: {
            type: "SI",
            companyRegister: siret,
            branchCode: code_commune
          },
          accessMode: nil,
          notificationFrequency: "unitaire",
          activateDateTime: nil,
          validateDateTime: validated_at.iso8601,
          rejectDateTime: nil,
          endDateTime: nil,
          updateDateTime: updated_at.iso8601,
          delegationActor: nil,
          rejectionReason: nil,
          status: "Inactif",
          email: administrateur_metier_data[:email],
          localAdministrator: {
            email: administrateur_metier_data[:email],
            firstName: administrateur_metier_data[:given_name],
            lastName: administrateur_metier_data[:family_name],
            function: administrateur_metier_data[:job_title],
            phoneNumber: administrateur_metier_data[:phone_number].delete(" ").delete(".").delete("-"),
            mobileNumber: nil
          }
        },
        api_key: access_token,
        tag: "Portail HubEE"
      })

      subscription_ids.push create_subscription_response.parse["id"]
    end

    subscription_ids.join(",")
  end
end
