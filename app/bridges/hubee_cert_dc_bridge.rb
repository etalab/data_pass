class HubEECertDCBridge < ApplicationBridge

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
    # @authorization_request.update({ linked_token_manager_id: linked_token_manager_id })
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
    etablissement = INSEESireneAPIClient.new.etablissement(siret: siret)["etablissement"]

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

  def format_etablissement(etablissement)
    is_diffusable = etablissement["statutDiffusionEtablissement"] == "O"

    last_periode_etablissement = etablissement["periodesEtablissement"][0]
    etat_administratif = last_periode_etablissement["etatAdministratifEtablissement"]

    if etat_administratif != "A" # || !is_diffusable
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
        etat_administratif: etat_administratif
      }
    end

    unite_legale = etablissement["uniteLegale"]
    adresse_etablissement = etablissement["adresseEtablissement"]

    nom_raison_sociale = unite_legale["denominationUniteLegale"]
    nom_raison_sociale ||= last_periode_etablissement["denominationUsuelleEtablissement"]
    nom = unite_legale["nomUniteLegale"]
    prenom_1 = unite_legale["prenom1UniteLegale"]
    prenom_2 = unite_legale["prenom2UniteLegale"]
    prenom_3 = unite_legale["prenom3UniteLegale"]
    prenom_4 = unite_legale["prenom4UniteLegale"]
    nom_raison_sociale ||= [prenom_1, prenom_2, prenom_3, prenom_4, nom].reject(&:nil?).join(" ")

    numero_voie = adresse_etablissement["numeroVoieEtablissement"]
    indice_repetition = adresse_etablissement["indiceRepetitionEtablissement"]
    type_voie = adresse_etablissement["typeVoieEtablissement"]
    libelle_voie = adresse_etablissement["libelleVoieEtablissement"]
    adresse = [numero_voie, indice_repetition, type_voie, libelle_voie].reject(&:nil?).join(" ")

    denomination = unite_legale["denominationUniteLegale"]
    sigle = unite_legale["sigleUniteLegale"]
    code_postal = adresse_etablissement["codePostalEtablissement"]
    code_commune = adresse_etablissement["codeCommuneEtablissement"]
    libelle_commune = adresse_etablissement["libelleCommuneEtablissement"]
    activite_principale = last_periode_etablissement["activitePrincipaleEtablissement"]
    activite_principale ||= unite_legale["activitePrincipaleUniteLegale"]
    activite_principale_label = CodeNAF.find(activite_principale.delete(".")).libelle
    categorie_juridique = unite_legale["categorieJuridiqueUniteLegale"]
    categorie_juridique_label = CategorieJuridique.where(code: categorie_juridique).first.libelle

    {
      nom_raison_sociale: nom_raison_sociale,
      siret: @authorization_request.organization[:siret],
      denomination: denomination,
      sigle: sigle,
      adresse: adresse,
      code_postal: code_postal,
      code_commune: code_commune,
      libelle_commune: libelle_commune,
      activite_principale: activite_principale,
      activite_principale_label: activite_principale_label,
      categorie_juridique: categorie_juridique,
      categorie_juridique_label: categorie_juridique_label,
      etat_administratif: etat_administratif
    }
  end

  def hubee_configuration = Rails.application.credentials.hubee
end
