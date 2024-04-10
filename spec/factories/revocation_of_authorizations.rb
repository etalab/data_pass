FactoryBot.define do
  factory :revocation_of_authorization do
    reason { 'une habilitation du même type est validé' }
    authorization_request factory: %i[authorization_request], state: 'revoked'
  end
end
