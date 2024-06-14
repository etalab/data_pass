class HubEECertDCBridge < ApplicationBridge
  def perform
    @authorization_request = @authorization_request.decorate

    administrateur_metier = @authorization_request.contact_data_by_type(:administrateur_metier)
    siret = @authorization_request.organization[:siret]
    updated_at = @authorization_request[:updated_at]
    validated_at = @authorization_request.last_validated_at
    scopes = @authorization_request.data['scopes']
    authorization_id = @authorization_request.authorizations.last.id

    linked_token_manager_id = create_enrollment_in_token_manager(
      authorization_id,
      administrateur_metier,
      siret,
      updated_at,
      validated_at,
      scopes
    )
    @authorization_request.update({ linked_token_manager_id: })
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
    etablissement = INSEESireneAPIClient.new.etablissement(siret:)['etablissement']

    response = format_etablissement(etablissement)

    denomination = response[:denomination]
    sigle = response[:sigle]
    code_postal = response[:code_postal]
    code_commune = response[:code_commune]
    libelle_commune = response[:libelle_commune]

    api_host = hubee_configuration[:host]
    hubee_auth_url = hubee_configuration[:auth_url]
    client_id = hubee_configuration[:client_id]
    client_secret = hubee_configuration[:client_secret]

    # 1. get token
    token_service = HubEEServiceAuthentication.new(client_id, client_secret, hubee_auth_url)
    token_response = token_service.retrieve_body
    access_token = JSON.parse(token_response.body)['access_token']

    # 2.1 get organization
    begin
      faraday_connection.get do |req|
        req.url "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}"
        req.headers['Authorization'] = "Bearer #{access_token}"
        req.headers['tag'] = 'Portail HubEE'
      end
    rescue Faraday::ResourceNotFound
      # 2.2 if organization does not exist, create the organization
      faraday_connection.post do |req|
        req.url "#{api_host}/referential/v1/organizations"
        req.headers['Authorization'] = "Bearer #{access_token}"
        req.headers['tag'] = 'Portail HubEE'
        req.body = {
          type: 'SI',
          companyRegister: siret,
          branchCode: code_commune,
          name: denomination,
          code: sigle,
          country: 'France',
          postalCode: code_postal,
          territory: libelle_commune,
          email: administrateur_metier_data[:email],
          phoneNumber: administrateur_metier_data[:phone_number].delete(' ').delete('.').delete('-'),
          status: 'Actif'
        }
      end
    end

    # 3. create subscriptions
    subscription_ids = []

    scopes = scopes.presence || ['CERTDC']

    scopes.each do |scope|
      create_subscription_response = faraday_connection.post do |req|
        req.url "#{api_host}/referential/v1/subscriptions"
        req.headers['Authorization'] = "Bearer #{access_token}"
        req.headers['tag'] = 'Portail HubEE'
        req.body = {
          datapassId: id,
          processCode: scope,
          subscriber: {
            type: 'SI',
            companyRegister: siret,
            branchCode: code_commune
          },
          accessMode: nil,
          notificationFrequency: 'unitaire',
          activateDateTime: nil,
          validateDateTime: validated_at.iso8601,
          rejectDateTime: nil,
          endDateTime: nil,
          updateDateTime: updated_at.iso8601,
          delegationActor: nil,
          rejectionReason: nil,
          status: 'Inactif',
          email: administrateur_metier_data[:email],
          localAdministrator: {
            email: administrateur_metier_data[:email],
            firstName: administrateur_metier_data[:given_name],
            lastName: administrateur_metier_data[:family_name],
            function: administrateur_metier_data[:job_title],
            phoneNumber: administrateur_metier_data[:phone_number].delete(' ').delete('.').delete('-'),
            mobileNumber: nil
          }
        }
      end

      subscription_ids.push (create_subscription_response)['id']
    end

    subscription_ids.join(',')
  end

  def format_etablissement(etablissement)
    etablissement['statutDiffusionEtablissement']

    last_periode_etablissement = etablissement['periodesEtablissement'][0]
    etat_administratif = last_periode_etablissement['etatAdministratifEtablissement']

    if etat_administratif != 'A' # || !is_diffusable
      return {
        nom_raison_sociale: nil,
        siret: @siret,
        denomination: nil,
        sigle: nil,
        adresse: nil,
        code_postal: nil,
        code_commune: nil,
        libelle_commune: nil,
        activite_principale: nil,
        activite_principale_label: nil,
        categorie_juridique: nil,
        categorie_juridique_label: nil,
        etat_administratif:
      }
    end

    unite_legale = etablissement['uniteLegale']
    adresse_etablissement = etablissement['adresseEtablissement']

    nom_raison_sociale = unite_legale['denominationUniteLegale']
    nom_raison_sociale ||= last_periode_etablissement['denominationUsuelleEtablissement']
    nom = unite_legale['nomUniteLegale']
    prenom_1 = unite_legale['prenom1UniteLegale']
    prenom_2 = unite_legale['prenom2UniteLegale']
    prenom_3 = unite_legale['prenom3UniteLegale']
    prenom_4 = unite_legale['prenom4UniteLegale']
    nom_raison_sociale ||= [prenom_1, prenom_2, prenom_3, prenom_4, nom].compact.join(' ')

    numero_voie = adresse_etablissement['numeroVoieEtablissement']
    indice_repetition = adresse_etablissement['indiceRepetitionEtablissement']
    type_voie = adresse_etablissement['typeVoieEtablissement']
    libelle_voie = adresse_etablissement['libelleVoieEtablissement']
    adresse = [numero_voie, indice_repetition, type_voie, libelle_voie].compact.join(' ')

    denomination = unite_legale['denominationUniteLegale']
    sigle = unite_legale['sigleUniteLegale']
    code_postal = adresse_etablissement['codePostalEtablissement']
    code_commune = adresse_etablissement['codeCommuneEtablissement']
    libelle_commune = adresse_etablissement['libelleCommuneEtablissement']
    activite_principale = last_periode_etablissement['activitePrincipaleEtablissement']
    activite_principale ||= unite_legale['activitePrincipaleUniteLegale']
    activite_principale_label = CodeNAF.find(activite_principale.delete('.')).libelle
    categorie_juridique = unite_legale['categorieJuridiqueUniteLegale']
    categorie_juridique_label = CategorieJuridique.where(code: categorie_juridique).first.libelle

    {
      nom_raison_sociale:,
      siret: @authorization_request.organization[:siret],
      denomination:,
      sigle:,
      adresse:,
      code_postal:,
      code_commune:,
      libelle_commune:,
      activite_principale:,
      activite_principale_label:,
      categorie_juridique:,
      categorie_juridique_label:,
      etat_administratif:
    }
  end

  def faraday_connection
    @faraday_connection ||= Faraday.new do |conn|
      conn.request :json
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json, :content_type => /\bjson$/
      conn.options.timeout = 2
      conn.adapter Faraday.default_adapter
    end
  end
  def hubee_configuration = Rails.application.credentials.hubee
end
