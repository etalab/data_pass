FactoryBot.define do
  factory :denial_of_authorization do
    reason { "Non-conformité avec l'article L214-1 du Code rural, relatif au bien-être animal" }
    authorization_request factory: %i[authorization_request], state: 'refused'
  end
end
