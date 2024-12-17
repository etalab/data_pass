FactoryBot.define do
  factory :authorization_request_instructor_draft do
    authorization_request_class { 'AuthorizationRequest::APIEntreprise' }
    data do
      {
        'what' => 'ever',
      }
    end

    after(:build) do |authorization_request_instructor_draft|
      authorization_request_trait = authorization_request_instructor_draft.authorization_request_class.demodulize.underscore

      authorization_request_instructor_draft.instructor ||= create(:user, :instructor, authorization_request_types: [authorization_request_trait])
    end

    trait :with_data do
      after(:build) do |authorization_request_instructor_draft|
        authorization_request_trait = authorization_request_instructor_draft.authorization_request_class.demodulize.underscore

        authorization_request_instructor_draft.data = build(:authorization_request, authorization_request_trait).data
      end
    end

    trait :with_applicant do
      applicant { create(:user) }

      after(:build) do |authorization_request_instructor_draft|
        authorization_request_instructor_draft.organization ||= authorization_request_instructor_draft.applicant.current_organization
      end
    end
  end
end
