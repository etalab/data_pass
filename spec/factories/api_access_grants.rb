FactoryBot.define do
  factory :api_access_grant, class: 'APIAccessGrant' do
    transient do
      definition { AuthorizationDefinition.find('api_entreprise') }
    end

    data_provider do
      DataProvider.find_by(slug: definition.provider_slug) || create(:data_provider, slug: definition.provider_slug)
    end
    oauth_application do
      association :oauth_application, owner: create(:user, :developer, authorization_request_types: [definition.id])
    end
    action { 'submission' }
    granted_by_email { 'admin@example.com' }
    grant_reason { 'Parcours qualifié par l’équipe DataPass' }
    granted_at { Time.current }

    trait :validation do
      action { 'validation' }
    end

    trait :revoked do
      revoked_by_email { 'admin@example.com' }
      revoke_reason { 'Le fournisseur a changé son parcours' }
      revoked_at { Time.current }
    end
  end
end
