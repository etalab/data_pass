FactoryBot.define do
  sequence(:email) { |n| "user#{n}@gouv.fr" }
  sequence(:external_id) { |n| (n + 10_000).to_s }

  factory :user do
    email
    family_name { 'Dupont' }
    given_name { 'Jean' }
    job_title { 'Adjoint au Maire' }
    email_verified { true }
    external_id

    transient do
      skip_organization_creation { false }
      authorization_request_types { %w[hubee_cert_dc api_entreprise] }
      data_provider_slugs { %w[dgfip] }
    end

    after(:build) do |user, evaluator|
      next if evaluator.skip_organization_creation

      organization = build(:organization)
      user.organizations_users.build(
        organization:,
        current: true
      )
    end

    %i[reporter instructor developer manager].each do |role|
      trait role do
        after(:create) do |user, evaluator|
          evaluator.authorization_request_types.each do |art|
            user.grant_role(role, art.to_s)
          rescue ParsedRole::UnknownDefinitionError
            UserRole.create!(user: user, role: role.to_s, data_provider_slug: 'unknown', authorization_definition_id: art.to_s)
          end
        end
      end

      trait :"fd_#{role}" do
        after(:create) do |user, evaluator|
          evaluator.data_provider_slugs.each do |slug|
            user.grant_fd_role(role, slug)
          end
        end
      end
    end

    trait :admin do
      after(:create, &:grant_admin_role)
    end
  end
end
