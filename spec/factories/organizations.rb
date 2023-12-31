FactoryBot.define do
  factory :organization do
    siret
    last_mon_compte_pro_updated_at { DateTime.now }

    after(:build) do |organization|
      organization.mon_compte_pro_payload = build(:organization_hash_from_mon_compte_pro, siret: organization.siret) if organization.mon_compte_pro_payload.blank?
    end
  end
end
