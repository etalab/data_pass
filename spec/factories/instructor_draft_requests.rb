FactoryBot.define do
  factory :instructor_draft_request do
    authorization_request_class { 'AuthorizationRequest::APIEntreprise' }
    data do
      {
        'what' => 'ever',
      }
    end

    after(:build) do |instructor_draft_request|
      authorization_request_trait = instructor_draft_request.authorization_request_class.demodulize.underscore

      instructor_draft_request.instructor ||= create(:user, :instructor, authorization_request_types: [authorization_request_trait])
      instructor_draft_request.form_uid ||= instructor_draft_request.definition.default_form.id
    end

    trait :with_data do
      after(:build) do |instructor_draft_request|
        next if instructor_draft_request.data.present?

        authorization_request_trait = instructor_draft_request.authorization_request_class.demodulize.underscore

        instructor_draft_request.data = build(:authorization_request, authorization_request_trait).data
      end
    end

    trait :with_applicant do
      applicant { create(:user) }

      after(:build) do |instructor_draft_request|
        instructor_draft_request.organization ||= instructor_draft_request.applicant.current_organization
      end
    end

    trait :with_documents do
      after(:create) do |instructor_draft_request|
        document = create(:instructor_draft_request_document, instructor_draft_request:)
        document.files.attach(
          io: Rails.root.join('spec/fixtures/dummy.pdf').open,
          filename: 'dummy.pdf',
          content_type: 'application/pdf'
        )
      end
    end

    trait :complete do
      with_data
      with_applicant
    end

    trait :claimed do
      complete
      claimed { true }
    end
  end
end
