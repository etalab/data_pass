FactoryBot.define do
  factory :bulk_authorization_request_update do
    authorization_definition_uid { AuthorizationDefinition.all.first.id }
    reason { 'Il fallait du changement' }
    application_date { Date.yesterday }
  end
end
