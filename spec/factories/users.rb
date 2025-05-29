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

    transient do
      skip_organization_creation { false }
    end

    after(:build) do |user, evaluator|
      next if evaluator.skip_organization_creation

      organization = build(:organization)
      user.organizations_users.build(
        organization:,
        current: true
      )
    end

    trait :reporter do
      transient do
        authorization_request_types do
          %w[hubee_cert_dc api_entreprise]
        end
      end

      after(:build) do |user, evaluator|
        evaluator.authorization_request_types.each do |authorization_request_type|
          user.roles << "#{authorization_request_type}:reporter"
        end
      end
    end

    trait :instructor do
      transient do
        authorization_request_types do
          %w[hubee_cert_dc api_entreprise]
        end
      end

      after(:build) do |user, evaluator|
        evaluator.authorization_request_types.each do |authorization_request_type|
          user.roles << "#{authorization_request_type}:instructor"
        end
      end
    end

    trait :developer do
      transient do
        authorization_request_types do
          %w[hubee_cert_dc api_entreprise]
        end
      end

      after(:build) do |user, evaluator|
        evaluator.authorization_request_types.each do |authorization_request_type|
          user.roles << "#{authorization_request_type}:developer"
        end
      end
    end

    trait :admin do
      after(:build) do |user|
        user.roles << 'admin'
      end
    end
  end
end
