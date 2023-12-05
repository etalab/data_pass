FactoryBot.define do
  sequence(:email) { |n| "user#{n}@gouv.fr" }
  sequence(:external_id, &:to_s)

  factory :user do
    email
    family_name { 'Dupont' }
    given_name { 'Jean' }
    job_title { 'Adjoint au Maire' }
    email_verified { true }
    external_id

    trait :with_organization do
      after(:build) do |user|
        user.organizations << build(:organization)
      end
    end
  end
end
