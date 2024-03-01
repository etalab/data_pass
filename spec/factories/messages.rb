FactoryBot.define do
  factory :message do
    from { build(:user) }
    authorization_request
    body { 'Hello' }

    trait :system do
      from { nil }
    end

    trait :from_applicant

    trait :from_instructor do
      from { build(:user, :instructor) }
    end
  end
end
