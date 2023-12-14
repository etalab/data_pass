FactoryBot.define do
  factory :authorization_request do
    initialize_with do
      attributes[:type].constantize.new(attributes.stringify_keys)
    end

    terms_of_service_accepted { true }
    data_protection_officer_informed { true }

    trait :no_checkboxes do
      terms_of_service_accepted { false }
      data_protection_officer_informed { false }
    end

    transient do
      fill_all_attributes { false }
    end

    trait :submitted do
      state { 'submitted' }
      fill_all_attributes { true }
    end

    after(:build) do |authorization_request|
      if authorization_request.applicant.nil? && authorization_request.organization.nil?
        applicant = create(:user)
        organization = create(:organization)
        applicant.organizations << organization

        authorization_request.applicant = applicant
        authorization_request.organization = organization
      elsif authorization_request.applicant.nil?
        applicant = create(:user)
        organization.users << applicant

        authorization_request.applicant = applicant
      elsif authorization_request.organization.nil?
        applicant = authorization_request.applicant
        organization = applicant.organizations.first || create(:organization)
        organization.users << applicant if organization.users.exclude?(applicant)

        authorization_request.organization = organization
      end
    end

    hubee_cert_dc

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

    trait :with_contacts do
      after(:build) do |authorization_request, evaluator|
        if authorization_request.need_complete_validation? || evaluator.fill_all_attributes
          authorization_request.class.contact_types.each do |contact_type|
            authorization_request.public_send("#{contact_type}_family_name=", "Dupont #{contact_type.to_s.humanize}")
            authorization_request.public_send("#{contact_type}_given_name=", "Jean #{contact_type.to_s.humanize}")
            authorization_request.public_send("#{contact_type}_email=", "jean.dupont.#{contact_type}@gouv.fr")
            authorization_request.public_send("#{contact_type}_phone_number=", '0836656565')
            authorization_request.public_send("#{contact_type}_job_title=", "Directeur #{contact_type.to_s.humanize}")
          end
        end
      end
    end

    trait :hubee_cert_dc do
      type { 'AuthorizationRequest::HubEECertDC' }

      with_contacts
    end

    trait :api_entreprise do
      type { 'AuthorizationRequest::APIEntreprise' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
      with_contacts
    end
  end
end
