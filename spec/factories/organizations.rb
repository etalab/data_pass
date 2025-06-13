FactoryBot.define do
  factory :organization do
    legal_entity_registry { 'insee_sirene' }

    trait :foreign do
      legal_entity_id { '0000000107219812' }
      legal_entity_registry { 'isni' }
    end

    transient do
      siret { generate(:siret) }
      name { nil }
      identity_federator { 'mon_compte_pro' }
    end

    after(:build) do |organization, evaluator|
      organization.legal_entity_id ||= evaluator.siret if organization.legal_entity_registry == 'insee_sirene'

      case evaluator.identity_federator
      when 'mon_compte_pro'
        organization.mon_compte_pro_payload = build(:organization_hash_from_mon_compte_pro, siret: organization.siret, label: evaluator.name) if organization.mon_compte_pro_payload.blank?
        organization.last_mon_compte_pro_updated_at = DateTime.now if organization.mon_compte_pro_payload.present?
      when 'proconnect'
        organization.proconnect_payload = build(:organization_hash_from_proconnect, siret: organization.siret) if organization.proconnect_payload.blank?
        organization.last_proconnect_updated_at = DateTime.now if organization.proconnect_payload.present?
      end

      if Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").exist?
        organization.insee_payload = JSON.parse(Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").read)
        organization.last_insee_payload_updated_at = DateTime.now
      end
    end
  end
end
