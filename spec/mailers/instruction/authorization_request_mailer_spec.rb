RSpec.describe Instruction::AuthorizationRequestMailer do
  describe '#submitted' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).submitted
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notification_for_api_particulier: false) }
    let!(:instructor_without_notification) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_submit_notification_for_api_entreprise: false) }
    let!(:instructor_for_another_authorization) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    it 'sends the email to the instructors with notification on' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match("demande d'habilitation")
      expect(mail.body.encoded).to match('a soumis')
      expect(mail.body.encoded).to match(authorization_request.applicant.email)
    end
  end

  describe '#reopening_submitted' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_submitted
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    it 'sends the email to the instructors with notification on' do
      expect(mail.to).to eq([valid_instructor.email])
    end

    it 'renders valid template' do
      expect(mail.body.encoded).to match('demande de réouverture')
      expect(mail.body.encoded).to match('a soumis')
      expect(mail.body.encoded).to match(authorization_request.applicant.email)
    end
  end
end
