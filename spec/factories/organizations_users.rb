FactoryBot.define do
  factory :organizations_user do
    organization
    user
    current { false }

    trait :current do
      current { true }
    end
  end
end
