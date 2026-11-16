FactoryBot.define do
  factory :european_wallet_subscriber do
    sequence(:email) { |n| "inscrit#{n}@example.com" }
    profile { 'organization' }
  end
end
