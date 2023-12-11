FactoryBot.define do
  factory :authorization_request do
    initialize_with do
      attributes[:type].constantize.new(attributes.stringify_keys)
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

      authorization_request.class.contact_types.each do |contact_type|
        authorization_request.public_send("#{contact_type}_family_name=", "Dupont #{contact_type.to_s.humanize}")
        authorization_request.public_send("#{contact_type}_given_name=", "Jean #{contact_type.to_s.humanize}")
        authorization_request.public_send("#{contact_type}_email=", "jean.dupont.#{contact_type}@gouv.fr")
        authorization_request.public_send("#{contact_type}_phone_number=", '0836656565')
        authorization_request.public_send("#{contact_type}_job_title=", "Directeur #{contact_type.to_s.humanize}")
      end
    end

    hubee_cert_dc

    trait :with_basic_infos do
      intitule { 'Demande d\'accès à la plateforme fournisseur' }

      after(:build) do |authorization_request|
        authorization_request.description = 'Description de la demande' if authorization_request.need_complete_validation?
      end
    end

    trait :hubee_cert_dc do
      type { 'AuthorizationRequest::HubEECertDC' }
    end
  end
end
