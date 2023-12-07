FactoryBot.define do
  sequence(:siret) { Faker::Company.french_siret_number }

  factory :mon_compte_pro_omniauth_payload, class: Hash do
    initialize_with { attributes.stringify_keys }

    info { association(:mon_compte_pro_payload) }

    after(:build) do |payload|
      payload['uid'] = payload['info']['sub']
    end
  end

  factory :mon_compte_pro_payload, class: Hash do
    initialize_with { attributes.stringify_keys }

    sub { generate(:external_id) }
    email
    email_verified { true }
    family_name { 'Dupont' }
    given_name { 'Jean' }
    job { 'Maire' }
    updated_at { DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%LZ') }
    phone_number { '0836656565' }
    phone_number_verified { false }

    label { 'Commune de Nantes - Mairie' }
    siret
    is_collectivite_territoriale { true }
    is_commune { true }
    is_service_public { true }
    is_external { false }
  end

  factory :organization_hash_from_mon_compte_pro, class: Hash do
    initialize_with { attributes.stringify_keys }

    label { 'Commune de Nantes - Mairie' }
    siret
    is_collectivite_territoriale { true }
    is_commune { true }
    is_service_public { true }
    siret
    is_external { true }
  end
end
