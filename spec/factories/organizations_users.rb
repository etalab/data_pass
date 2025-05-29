FactoryBot.define do
  factory :organizations_user do
    organization
    user
    identity_provider_uid { User::IDENTITY_PROVIDERS.key('mon_compte_pro') }
    current { false }

    trait :current do
      current { true }
    end
  end
end
