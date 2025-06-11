FactoryBot.define do
  factory :impersonation_action do
    association :impersonation
    action { 'create' }
    model_type { 'AuthorizationRequest' }
    model_id { 1 }
  end
end
