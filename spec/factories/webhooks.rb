FactoryBot.define do
  factory :webhook do
    authorization_definition_id { 'api_entreprise' }
    url { 'https://webhook.site/test' }
    sequence(:secret) { |n| "secret_token_#{n}" }
    events { %w[approve submit] }
    enabled { false }
    validated { false }
    activated_at { nil }

    trait :validated do
      validated { true }
      activated_at { Time.current }
    end

    trait :enabled do
      enabled { true }
    end

    trait :active do
      validated { true }
      enabled { true }
      activated_at { Time.current }
      events { Webhook::VALID_EVENTS }
    end

    trait :with_all_events do
      events { Webhook::VALID_EVENTS }
    end
  end
end
