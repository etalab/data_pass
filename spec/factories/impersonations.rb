FactoryBot.define do
  factory :impersonation do
    user
    admin factory: %i[user]
    reason { 'Support request #12345' }
  end
end
