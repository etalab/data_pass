FactoryBot.define do
  factory :authorization_request_event do
    name { 'create' }
    user
    entity factory: %i[authorization_request api_entreprise]

    transient do
      authorization_request { nil }
    end

    trait :entity_is_authorization_request do
      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = evaluator.authorization_request
      end
    end

    trait :create do
      entity_is_authorization_request
    end

    trait :update do
      entity_is_authorization_request

      name { 'update' }
    end

    trait :submit do
      name { 'submit' }

      entity factory: %i[authorization_request_changelog]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:authorization_request_changelog, authorization_request: evaluator.authorization_request)
      end
    end

    trait :approve do
      name { 'approve' }

      entity factory: %i[authorization]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:authorization, request: evaluator.authorization_request)
      end
    end

    trait :refuse do
      name { 'refuse' }

      entity factory: %i[denial_of_authorization]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:denial_of_authorization, authorization_request: evaluator.authorization_request)
      end
    end

    trait :revoke do
      name { 'revoke' }

      entity factory: %i[revocation_of_authorization]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:revocation_of_authorization, authorization_request: evaluator.authorization_request)
      end
    end

    trait :request_changes do
      name { 'request_changes' }

      entity factory: %i[instructor_modification_request]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:instructor_modification_request, authorization_request: evaluator.authorization_request)
      end
    end

    trait :archive do
      entity_is_authorization_request

      name { 'archive' }
    end

    trait :reopen do
      name { 'reopen' }

      entity factory: %i[authorization]

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:authorization, request: evaluator.authorization_request)
      end
    end

    trait :copy do
      entity factory: %i[authorization_request api_entreprise]
      entity_is_authorization_request

      name { 'copy' }

      after(:build) do |authorization_request_event|
        authorization_request = authorization_request_event.entity
        authorization_request_trait = authorization_request.type.split('::').last.underscore.to_sym

        copied_from_authorization_request = create(:authorization_request, :validated, authorization_request_trait, applicant: authorization_request.applicant)

        authorization_request_event.entity.copied_from_request = copied_from_authorization_request
      end
    end

    trait :applicant_message do
      name { 'applicant_message' }

      entity { build(:message, :from_applicant) }

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:message, authorization_request: evaluator.authorization_request)
      end
    end

    trait :instructor_message do
      name { 'instructor_message' }

      entity { build(:message, :from_instructor) }

      after(:build) do |authorization_request_event, evaluator|
        next if evaluator.authorization_request.blank?

        authorization_request_event.entity = build(:message, authorization_request: evaluator.authorization_request)
      end
    end

    trait :admin_update do
      name { 'admin_update' }

      entity factory: %i[authorization_request_changelog]

      after(:build) do |authorization_request_event, evaluator|
        authorization_request_event.entity = build(:authorization_request_changelog, authorization_request: evaluator.authorization_request) if evaluator.authorization_request.present?

        authorization_request_event.entity.diff.delete 'scopes'
      end
    end

    trait :system_reminder do
      name { 'system_reminder' }

      entity_is_authorization_request

      user { nil }
    end

    trait :system_archive do
      name { 'system_archive' }

      entity_is_authorization_request

      user { nil }
    end
  end
end
