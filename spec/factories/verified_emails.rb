FactoryBot.define do
  factory :verified_email do
    email
    status { 'deliverable' }
    verified_at { Time.zone.now }
  end
end
