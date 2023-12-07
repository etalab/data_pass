FactoryBot.define do
  sequence(:email) { |n| "user#{n}@gouv.fr" }
  sequence(:external_id, &:to_s)

  factory :user do
    email
    family_name { 'Dupont' }
    given_name { 'Jean' }
    job_title { 'Adjoint au Maire' }
    email_verified { true }
    external_id

    after(:build) do |user|
      user.current_organization ||= build(:organization, users: [user])
      user.organizations << user.current_organization
    end
  end
end
