FactoryBot.define do
  factory :authorization_request do
    initialize_with do
      attributes[:type].constantize.new(attributes.stringify_keys)
    end

    terms_of_service_accepted { true }
    data_protection_officer_informed { true }
    form_uid { 'portail-hubee-demarche-certdc' }
    type { 'AuthorizationRequest::HubEECertDC' }

    after(:build) do |authorization_request, evaluator|
      if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
        authorization_request.class.contact_types.each do |contact_type|
          authorization_request.public_send(:"#{contact_type}_family_name=", "Dupont #{contact_type.to_s.humanize}")
          authorization_request.public_send(:"#{contact_type}_given_name=", "Jean #{contact_type.to_s.humanize}")
          authorization_request.public_send(:"#{contact_type}_email=", "jean.dupont.#{contact_type}@gouv.fr")
          authorization_request.public_send(:"#{contact_type}_phone_number=", '0836656565')
          authorization_request.public_send(:"#{contact_type}_job_title=", "Directeur #{contact_type.to_s.humanize}")
        end
      end
    end

    after(:build) do |authorization_request|
      if authorization_request.applicant.nil? && authorization_request.organization.nil?
        applicant = create(:user)
        organization = create(:organization)
        applicant.organizations << organization

        authorization_request.applicant = applicant
        authorization_request.organization = organization
      elsif authorization_request.applicant.nil?
        applicant = create(:user, current_organization: authorization_request.organization)
        authorization_request.organization.users << applicant

        authorization_request.applicant = applicant
      elsif authorization_request.organization.nil?
        applicant = authorization_request.applicant
        organization = applicant.organizations.first || create(:organization)
        organization.users << applicant if organization.users.exclude?(applicant)

        authorization_request.organization = organization
      end
    end

    transient do
      fill_all_attributes { false }
    end

    trait :no_checkboxes do
      terms_of_service_accepted { false }
      data_protection_officer_informed { false }
    end

    trait :draft do
      state { 'draft' }
    end

    trait :archived do
      state { 'archived' }
    end

    trait :revoked do
      state { 'revoked' }
    end

    trait :changes_requested do
      state { 'changes_requested' }

      after(:build) do |authorization_request|
        authorization_request.modification_requests << build(:instructor_modification_request, authorization_request:)
      end
    end

    trait :submitted do
      state { 'submitted' }
      fill_all_attributes { true }
    end

    trait :refused do
      state { 'refused' }
      fill_all_attributes { true }

      after(:build) do |authorization_request|
        authorization_request.denials << build(:denial_of_authorization, authorization_request:)
      end
    end

    trait :validated do
      state { 'validated' }
      fill_all_attributes { true }
      last_validated_at { Time.zone.now }
    end

    trait :with_basic_infos do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.intitule ||= 'Demande d\'accès à la plateforme fournisseur'
          authorization_request.description ||= 'Description de la demande'
        end
      end
    end

    trait :with_personal_data do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.destinataire_donnees_caractere_personnel = 'Agents'
          authorization_request.duree_conservation_donnees_caractere_personnel = 1
        end
      end
    end

    trait :with_cadre_juridique do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.cadre_juridique_nature ||= 'Loi numérique'
          authorization_request.cadre_juridique_url ||= 'https://www.legifrance.gouv.fr/affichTexte.do?cidTexte=JORFTEXT000000886460'
        end
      end
    end

    trait :with_scopes do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.scopes ||= []
          authorization_request.scopes << authorization_request.available_scopes.first
        end
      end
    end

    trait :hubee_cert_dc do
      type { 'AuthorizationRequest::HubEECertDC' }
    end

    trait :portail_hubee_demarche_certdc do
      hubee_cert_dc

      form_uid { 'portail-hubee-demarche-certdc' }
    end

    trait :api_entreprise do
      type { 'AuthorizationRequest::APIEntreprise' }
      form_uid { 'api-entreprise' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end

    trait :api_entreprise_marches_publics do
      api_entreprise
      form_uid { 'api-entreprise-marches-publics' }
    end

    trait :api_entreprise_mgdis do
      api_entreprise
      form_uid { 'api-entreprise-mgdis' }
    end

    trait :api_entreprise_setec_atexo do
      api_entreprise
      form_uid { 'api-entreprise-setec-atexo' }
    end

    trait :api_particulier do
      type { 'AuthorizationRequest::APIParticulier' }
      form_uid { 'api-particulier' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end

    trait :api_infinoe_sandbox do
      type { 'AuthorizationRequest::APIInfinoeSandbox' }
      form_uid { 'api-infinoe-sandbox' }

      with_basic_infos
      with_cadre_juridique
    end

    trait :api_infinoe_production do
      type { 'AuthorizationRequest::APIInfinoeProduction' }
      form_uid { 'api-infinoe-production' }

      homologation_autorite_nom { 'Autorité de homologation' }
      homologation_autorite_fonction { 'Fonction de l\'autorité de homologation' }
      homologation_date_debut { 51.months.ago.to_date }
      homologation_date_fin { 42.years.from_now.to_date }

      volumetrie_appels_par_minute { '1000' }
      recette_fonctionnelle { '1' }

      after(:build) do |authorization_request, _evaluator|
        authorization_request.sandbox_authorization_request ||= create(
          :authorization_request,
          :api_infinoe_sandbox,
          :validated,
          applicant: authorization_request.applicant,
          organization: authorization_request.organization,
        )
      end
    end

    trait :api_service_national do
      type { 'AuthorizationRequest::APIServiceNational' }
      form_uid { 'api-service-national' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
    end

    trait :api_service_national_inscription_concours_examen do
      api_service_national
      form_uid { 'api-service-national-inscription-concours-examen' }
    end

    trait :api_service_national_obligation_service_national do
      api_service_national
      form_uid { 'api-service-national-obligation-service-national' }
    end
  end
end
