FactoryBot.define do
  factory :hubee_organization_payload, class: Hash do
    initialize_with { attributes.deep_stringify_keys }

    transient do
      organization { nil }
      authorization_request { nil }
    end

    after(:build) do |hubee_organization_payload, evaluator|
      if evaluator.organization.present?
        hubee_organization_payload['companyRegister'] = evaluator.organization.siret
        hubee_organization_payload['branchCode'] = evaluator.organization.code_commune
        hubee_organization_payload['name'] = evaluator.organization.denomination
        hubee_organization_payload['code'] = evaluator.organization.sigle_unite_legale
        hubee_organization_payload['postalCode'] = evaluator.organization.code_postal
        hubee_organization_payload['territory'] = evaluator.organization.libele_commune
      end

      if evaluator.authorization_request.present?
        hubee_organization_payload['email'] = evaluator.authorization_request.administrateur_metier_email
        hubee_organization_payload['phoneNumber'] = evaluator.authorization_request.administrateur_metier_phone_number.gsub(/[ .-]/, '')
      end
    end

    type { 'SI' }
    companyRegister { '21920023500014' }
    branchCode { '92023' }
    name { 'COMMUNE DE CLAMART' }
    code { nil }
    country { 'France' }
    postalCode { '92140' }
    territory { 'CLAMART' }
    email { 'admin@yopmail.com' }
    phoneNumber { '0123456789' }
    status { 'Actif' }
  end

  factory :hubee_subscription_payload, class: Hash do
    initialize_with { attributes.deep_stringify_keys }

    transient do
      authorization_request { nil }
    end

    transient do
      organization { nil }
    end

    after(:build) do |hubee_subscription_payload, evaluator|
      if evaluator.authorization_request.present?
        hubee_subscription_payload['datapassId'] = evaluator.authorization_request.id
        hubee_subscription_payload['validateDateTime'] = evaluator.authorization_request.last_validated_at.iso8601
        hubee_subscription_payload['updateDateTime'] = evaluator.authorization_request.updated_at.iso8601
        hubee_subscription_payload['email'] = evaluator.authorization_request.administrateur_metier_email
        hubee_subscription_payload['localAdministrator'] = { 'email' => evaluator.authorization_request.administrateur_metier_email }
      end

      hubee_subscription_payload['subscriber'] =
        if evaluator.organization.present?
          {
            'type' => 'SI',
            'companyRegister' => evaluator.organization.siret,
            'branchCode' => evaluator.organization.code_commune,
          }
        end
    end

    datapassId { 1 }
    processCode { 'SOME CODE' }
    subscriber do
      nil
    end
    notificationFrequency { 'unitaire' }
    validateDateTime { '2024-07-18T14:00:55+02:00' }
    updateDateTime { '2024-07-18T14:00:55+02:00' }
    status { 'Inactif' }
    email { 'admin@yopmail.com' }
    localAdministrator { { 'email' => 'admin@yopmail.com' } }

    trait :cert_dc do
      processCode { 'CERTDC' }
    end

    factory :hubee_subscription_response_payload do
      id { '22' }
      accessMode { nil }
      activateDateTime { nil }
      creationDateTime { '2024-07-18T14:00:55+02:00' }
      delegationActor { nil }
      endDateTime { nil }
      rejectDateTime { nil }
      rejectionReason { nil }
    end
  end

  factory :hubee_error_payload, class: Hash do
    initialize_with { attributes.deep_stringify_keys }

    transient do
      code { 400 }
      message { 'Some error message' }
    end

    errors do
      [{ code:, message: }]
    end

    trait :organization_missing_params do
      message { 'Bad Request : Validation failed.\n[ERROR][REQUEST][POST /referential/v1/organizations @body] Object has missing required properties ([\"branchCode\",\"companyRegister\",\"email\",\"name\",\"postalCode\",\"status\",\"territory\",\"type\"])' }
    end

    trait :organization_already_exists do
      message { 'Organization SI-21050136700010-00000 already exists' }
    end

    trait :subscription_already_exists do
      message { 'Subscription CERTDC for organization SI-21920023500014-92023 already exists' }
    end

    trait :subscription_validation_failed do
      message { 'Bad Request : Validation failed.\n[ERROR][REQUEST][POST /referential/v1/subscriptions @body] Instance failed to match all required schemas (matched only 1 out of 2)\n\t* /allOf/0: Object has missing required properties ([\"datapassId\",\"localAdministrator\",\"notificationFrequency\",\"processCode\",\"subscriber\"])\t\n\t- [ERROR] Object has missing required properties ([\"datapassId\",\"localAdministrator\",\"notificationFrequency\",\"processCode\",\"subscriber\"])' }
    end

    trait :internal_server_error do
      code { 500 }
      message { 'Internal Server Error' }
    end
  end
end
