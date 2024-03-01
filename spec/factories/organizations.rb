FactoryBot.define do
  factory :organization do
    siret
    last_mon_compte_pro_updated_at { DateTime.now }

    after(:build) do |organization|
      organization.mon_compte_pro_payload = build(:organization_hash_from_mon_compte_pro, siret: organization.siret) if organization.mon_compte_pro_payload.blank?

      if Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").exist?
        organization.insee_payload = JSON.parse(Rails.root.join('spec', 'fixtures', 'insee', "#{organization.siret}.json").read)
        organization.last_insee_payload_updated_at = DateTime.now
      end
    end
  end
end
