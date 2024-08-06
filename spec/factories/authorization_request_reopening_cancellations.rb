FactoryBot.define do
  factory :authorization_request_reopening_cancellation do
    trait :from_applicant

    request factory: :authorization_request

    after(:build) do |authorization_request_reopening_cancellation|
      authorization_request_reopening_cancellation.user ||= authorization_request_reopening_cancellation.request.applicant
    end

    trait :from_instructor do
      reason { 'Pas d\'activité depuis plusieurs semaines' }

      after(:build) do |authorization_request_reopening_cancellation|
        type_underscorded = authorization_request_reopening_cancellation.request.class.name.underscore.split('/').last

        authorization_request_reopening_cancellation.user = create(:user, :instructor, authorization_request_types: [type_underscorded])
      end
    end
  end
end
