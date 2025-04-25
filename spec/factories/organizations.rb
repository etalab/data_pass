FactoryBot.define do
  factory :organization do
    legal_entity_registry { 'insee_sirene' }
    last_mon_compte_pro_updated_at { DateTime.now }

    trait :foreign do
      legal_entity_id { '0000000107219812' }
      legal_entity_registry { 'isni' }
    end

    transient do
      siret { generate(:siret) }
      name { nil }
    end

    after(:build) do |organization, evaluator|
      organization.legal_entity_id ||= evaluator.siret if organization.legal_entity_registry == 'insee_sirene'

      organization.mon_compte_pro_payload = build(:organization_hash_from_mon_compte_pro, siret: organization.siret, label: evaluator.name) if organization.mon_compte_pro_payload.blank?

      if Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").exist?
        organization.insee_payload = JSON.parse(Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").read)
        organization.last_insee_payload_updated_at = DateTime.now
      end
    end
  end
end
