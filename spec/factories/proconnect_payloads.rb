FactoryBot.define do
  factory :proconnect_omniauth_payload, class: Hash do
    initialize_with { attributes.stringify_keys }

    transient do
      data_identity_id { SecureRandom.uuid }
      siret
    end

    provider { 'proconnect' }
    info { build(:proconnect_info_payload) }
    credentials { {} }
    extra { { 'raw_info' => build(:proconnect_raw_info_payload) } }

    after(:build) do |payload, evaluator|
      payload['extra']['raw_info'].stringify_keys!

      payload['uid'] = payload['info']['uid']

      payload['extra']['raw_info']['idp_id'] = evaluator.data_identity_id || (raise 'data_identity_id is required for proconnect_omniauth_payload factory')
      payload['extra']['raw_info']['siret'] = evaluator.siret || (raise 'siret is required for proconnect_omniauth_payload factory')

      payload['info']['uid'] ||= payload['extra']['raw_info']['uid']
      payload['info']['first_name'] ||= payload['extra']['raw_info']['given_name']
      payload['info']['last_name'] ||= payload['extra']['raw_info']['usual_name']
      payload['info']['name'] ||= "#{payload['info']['last_name']} #{payload['info']['first_name']}"
      payload['info']['email'] ||= payload['extra']['raw_info']['email']
      payload['info']['phone'] ||= payload['extra']['raw_info']['phone_number']
    end
  end

  factory :proconnect_info_payload, class: Hash do
    initialize_with { attributes.stringify_keys }

    provider { 'proconnect' }
  end

  factory :proconnect_raw_info_payload, class: Hash do
    initialize_with { attributes.stringify_keys }

    sub { generate(:external_id) }
    uid { generate(:external_id) }

    given_name { 'Jean' }
    usual_name { 'Dupont' }
    email
    siret
    phone_number { '0123456789' }
    idp_id { nil }
    aud { generate(:external_id) }
    exp { Time.now.to_i + 3600 }
    iat { Time.now.to_i }
    iss { 'https://agentconnect.fr/api/v2' }
  end

  factory :organization_hash_from_proconnect, class: Hash do
    transient do
      data_identity_id { SecureRandom.uuid }
    end

    after(:build) do |payload, evaluator|
      payload['idp_id'] = evaluator.data_identity_id || (raise 'data_identity_id is required for organization_hash_from_proconnect factory')
    end

    initialize_with { attributes.stringify_keys }
    siret
  end
end
