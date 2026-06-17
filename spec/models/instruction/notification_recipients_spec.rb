RSpec.describe Instruction::NotificationRecipients do
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe '.submit' do
    subject(:recipients) { described_class.submit(authorization_request) }

    let!(:instructor_with_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
    let!(:instructor_without_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }
    let!(:reporter_with_notif) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }
    let!(:reporter_without_notif) { create(:user, :reporter, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }
    let!(:instructor_other_api) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    it 'includes instructors with notification on' do
      expect(recipients).to include(instructor_with_notif)
    end

    it 'excludes instructors with notification off' do
      expect(recipients).not_to include(instructor_without_notif)
    end

    it 'includes reporters with notification on' do
      expect(recipients).to include(reporter_with_notif)
    end

    it 'excludes reporters with notification off' do
      expect(recipients).not_to include(reporter_without_notif)
    end

    it 'excludes instructors for another API' do
      expect(recipients).not_to include(instructor_other_api)
    end

    context 'when the applicant is also an instructor with notification off' do
      let!(:applicant_instructor) do
        applicant = authorization_request.applicant
        applicant.grant_role(:instructor, 'api_entreprise')
        applicant.update!(instruction_submit_notifications_for_api_entreprise: false)
        applicant
      end

      it 'still includes the applicant (exception rule)' do
        expect(recipients).to include(applicant_instructor)
      end
    end
  end

  describe '.messages' do
    subject(:recipients) { described_class.messages(authorization_request) }

    let!(:instructor_with_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
    let!(:instructor_without_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_messages_notifications_for_api_entreprise: false) }
    let!(:manager_with_notif) { create(:user, :manager, authorization_request_types: %w[api_entreprise]) }
    let!(:manager_without_notif) { create(:user, :manager, authorization_request_types: %w[api_entreprise], instruction_messages_notifications_for_api_entreprise: false) }
    let!(:instructor_other_api) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    it 'includes instructors with notification on' do
      expect(recipients).to include(instructor_with_notif)
    end

    it 'excludes instructors with notification off' do
      expect(recipients).not_to include(instructor_without_notif)
    end

    it 'includes managers with notification on' do
      expect(recipients).to include(manager_with_notif)
    end

    it 'excludes managers with notification off' do
      expect(recipients).not_to include(manager_without_notif)
    end

    it 'excludes instructors for another API' do
      expect(recipients).not_to include(instructor_other_api)
    end

    context 'when the applicant is also an instructor with notification off' do
      let!(:applicant_instructor) do
        applicant = authorization_request.applicant
        applicant.grant_role(:instructor, 'api_entreprise')
        applicant.update!(instruction_messages_notifications_for_api_entreprise: false)
        applicant
      end

      it 'still includes the applicant (exception rule)' do
        expect(recipients).to include(applicant_instructor)
      end
    end
  end

  describe 'parity with legacy filters' do
    let!(:instructor_with_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notifications_for_api_particulier: false) }
    let!(:instructor_without_notif) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }
    let!(:reporter_with_notif) { create(:user, :reporter, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notifications_for_api_particulier: false) }
    let!(:reporter_without_notif) { create(:user, :reporter, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }

    it 'submit returns same recipients as the legacy AbstractInstructionMailer filter' do
      legacy_result = authorization_request.definition.instructors_or_reporters.reject do |user|
        !user.public_send(:"instruction_submit_notifications_for_#{authorization_request.definition.id.underscore}") &&
          user != authorization_request.applicant
      end

      expect(described_class.submit(authorization_request)).to match_array(legacy_result)
    end

    it 'messages returns same recipients as the legacy MessageMailer filter' do
      legacy_result = authorization_request.definition.instructors_and_managers.reject do |instructor|
        !instructor.public_send(:"instruction_messages_notifications_for_#{authorization_request.definition.id.underscore}") &&
          instructor != authorization_request.applicant
      end

      expect(described_class.messages(authorization_request)).to match_array(legacy_result)
    end
  end
end
