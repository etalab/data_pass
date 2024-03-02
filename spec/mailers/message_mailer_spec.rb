RSpec.describe MessageMailer do
  describe '#to_applicant' do
    let(:mail) { described_class.with(message:).to_applicant }
    let(:message) { create(:message) }

    it 'sends the email to the applicant associated to authorization request message' do
      expect(mail.to).to eq([message.authorization_request.applicant.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
    end
  end

  describe '#to_instructors' do
    let(:mail) { described_class.with(message:).to_instructors }
    let(:message) { create(:message, authorization_request:) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier], instruction_messages_notifications_for_api_particulier: false) }
    let!(:instructor_without_notification) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_messages_notifications_for_api_entreprise: false) }
    let!(:instructor_for_another_authorization) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    it 'sends the email to the instructors with notification on' do
      expect(mail.to).to contain_exactly(valid_instructor.email)
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('un nouveau message')
    end
  end
end
