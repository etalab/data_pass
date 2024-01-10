FactoryBot.define do
  sequence(:email) { |n| "user#{n}@gouv.fr" }
  sequence(:external_id) { |n| (n + 100).to_s }

  factory :user do
    email
    family_name { 'Dupont' }
    given_name { 'Jean' }
    job_title { 'Adjoint au Maire' }
    email_verified { true }
    external_id

    after(:build) do |user|
      user.current_organization ||= build(:organization, users: [user])
      user.organizations << user.current_organization
    end

    trait :instructor do
      transient do
        authorization_request_types do
          %w[api_entreprise]
        end
      end

      after(:build) do |user, evaluator|
        evaluator.authorization_request_types.each do |authorization_request_type|
          user.roles << "#{authorization_request_type}:instructor"
        end
      end
    end
  end
end
