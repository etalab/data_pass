FactoryBot.define do
  factory :webhook_attempt do
    webhook
    authorization_request { association :authorization_request, :api_entreprise }
    event_name { 'approve' }
    status_code { 200 }
    response_body { '{"status": "ok"}' }
    payload { { event: 'approve', data: { id: 123 } } }

    trait :failed do
      status_code { 500 }
      response_body { '{"error": "Internal Server Error"}' }
    end

    trait :successful do
      status_code { 200 }
      response_body { '{"status": "ok"}' }
    end

    trait :with_long_response do
      response_body { 'x' * 15_000 }
    end
  end
end
