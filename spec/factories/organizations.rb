FactoryBot.define do
  factory :organization_hash_from_mon_compte_pro, class: Hash do
    initialize_with { attributes.stringify_keys }

    siret { Faker::Company.french_siret_number }
    is_external { true }
  end

  factory :organization do
    siret { Faker::Company.french_siret_number }
    last_mon_compte_pro_updated_at { DateTime.now }

    after(:build) do |organization|
      organization.mon_compte_pro_payload ||= build(:organization_hash_from_mon_compte_pro, siret: organization.siret)
    end
  end
end
