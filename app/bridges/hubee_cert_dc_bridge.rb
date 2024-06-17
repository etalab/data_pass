class HubEECertDCBridge < ApplicationBridge
  def perform
    authorization_request = @authorization_request.decorate
    administrateur_metier_data = authorization_request.contact_data_by_type(:administrateur_metier)
    siret = authorization_request.organization[:siret]
    scopes = authorization_request.data['scopes']
    id = authorization_request[:id]

    linked_token_manager_id = create_enrollment_in_token_manager(
      id,
      authorization_request,
      administrateur_metier_data,
      siret,
      scopes
    )
    @authorization_request.update({ linked_token_manager_id: })
  end

  private

  def create_enrollment_in_token_manager(
    id,
    authorization_request,
    administrateur_metier_data,
    siret,
    scopes
  )
    etablissement = INSEESireneAPIClient.new.etablissement(siret:)['etablissement']
    etablissement_response = format_etablissement(etablissement)

    access_token = get_token
    get_or_create_organization(access_token, siret, etablissement_response, administrateur_metier_data)
    create_subscription(access_token, id, authorization_request, etablissement_response, scopes, administrateur_metier_data)
  end

  def get_token
    hubee_auth_url = hubee_configuration[:auth_url]
    client_id = hubee_configuration[:client_id]
    client_secret = hubee_configuration[:client_secret]

    token_service = HubEE::HubEEServiceAuthentication.new(client_id, client_secret, hubee_auth_url)
    token_response = token_service.retrieve_body

    JSON.parse(token_response.body)['access_token']
  end

  def get_or_create_organization(access_token, siret, etablissement_response, administrateur_metier_data)
    api_host = hubee_configuration[:host]

    organization_service = HubEE::OrganizationService.new(api_host, access_token, siret, etablissement_response, administrateur_metier_data)
    organization_service.retrieve_or_create_organization
  end

  def create_subscription(access_token, id, authorization_request, etablissement_response, scopes, administrateur_metier_data)
    api_host = hubee_configuration[:host]

    subscription_ids = []

    scopes = scopes.presence || ['CERTDC']
    begin
      scopes.each do |scope|
        create_subscription_response = HubEE::SubscriptionService.new(api_host, access_token, id, authorization_request, etablissement_response, scope, administrateur_metier_data).create_subscriptions
        subscription_ids.push(create_subscription_response.body['id'])
      end
    rescue Faraday::BadRequestError => e
      Rails.logger.error(e)
      raise e
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
