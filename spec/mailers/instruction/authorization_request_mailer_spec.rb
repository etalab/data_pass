RSpec.describe Instruction::AuthorizationRequestMailer do
  describe '#submit' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).submit
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    context 'when there is instructors and reporters to notify' do
      let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notifications_for_api_particulier: false) }
      let!(:instructor_without_notification) { create(:user, :instructor, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }
      let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notifications_for_api_particulier: false) }
      let!(:reporter_without_notification) { create(:user, :reporter, authorization_request_types: %w[api_entreprise], instruction_submit_notifications_for_api_entreprise: false) }
      let!(:instructor_for_another_authorization) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

      it 'sends the email to the instructors and reporters with notification on' do
        expect(mail.to).to contain_exactly(valid_instructor.email, valid_reporter.email)
      end

      it 'renders valid template' do
        expect(mail.body.encoded).to match("demande d'habilitation")
        expect(mail.body.encoded).to match('a soumis')
        expect(mail.body.encoded).to match(authorization_request.applicant.email)
      end
    end

    context 'when there is no instructor nor reporter to notify' do
      it 'does not render any email' do
        expect(mail.body).to be_blank
      end
    end
  end

  describe '#reopening_submit' do
    subject(:mail) do
      described_class.with(
        authorization_request:
      ).reopening_submit
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    context 'when there is instructors to notify' do
      let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
      let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %w[api_entreprise api_particulier], instruction_submit_notifications_for_api_particulier: false) }

      it 'sends the email to the instructors with notification on' do
        expect(mail.to).to contain_exactly(valid_instructor.email, valid_reporter.email)
      end

      it 'renders valid template' do
        expect(mail.body.encoded).to match('demande de réouverture')
        expect(mail.body.encoded).to match('a soumis')
        expect(mail.body.encoded).to match(authorization_request.applicant.email)
      end
    end

    context 'when there is no instructor nor reporter to notify' do
      it 'does not render any email' do
        expect(mail.body).to be_blank
      end
    end
  end
end
