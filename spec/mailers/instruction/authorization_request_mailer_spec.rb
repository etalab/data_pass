RSpec.describe Instruction::AuthorizationRequestMailer do
  describe '#submit' do
    subject(:mail) do
      described_class.with(authorization_request:).submit
    end

    shared_examples 'submit notification behavior' do |api_type|
      let(:notification_setting) do
        case api_type
        when 'api_particulier'
          { instruction_submit_notifications_for_api_particulier: true }
        when 'api_impot_particulier_sandbox'
          { instruction_submit_notifications_for_api_impot_particulier_sandbox: true }
        else
          { instruction_submit_notifications_for_api_entreprise: true }
        end
      end

      let(:disabled_notification_setting) do
        case api_type
        when 'api_particulier'
          { instruction_submit_notifications_for_api_particulier: false }
        when 'api_impot_particulier_sandbox'
          { instruction_submit_notifications_for_api_impot_particulier_sandbox: false }
        else
          { instruction_submit_notifications_for_api_entreprise: false }
        end
      end

      context 'when there are instructors and reporters to notify' do
        let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: [api_type], **notification_setting) }
        let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: [api_type], **notification_setting) }
        let!(:instructor_without_notification) { create(:user, :instructor, authorization_request_types: [api_type], **disabled_notification_setting) }

        it 'sends the email to users with notifications enabled' do
          expect(mail.to).to contain_exactly(valid_instructor.email, valid_reporter.email)
        end

        it 'renders valid template' do
          expect(mail.body.encoded).to match("demande d'habilitation")
          expect(mail.body.encoded).to match('a soumis')
          expect(mail.body.encoded).to match(authorization_request.applicant.email)
        end

        context 'when the authorization request has a modification request' do
          before { create(:instructor_modification_request, authorization_request:) }

          it 'includes the changes_requested_submit message' do
            expect(mail.body.encoded).to match('Cette demande fait suite à une demande de modification.')
          end
        end

        context 'when the authorization request does not have a modification request' do
          it 'does not include the changes_requested_submit message' do
            expect(mail.body.encoded).not_to match('Cette demande fait suite à une demande de modification.')
          end
        end
      end

      context 'when there is no instructor nor reporter to notify' do
        it 'does not render any email' do
          expect(mail.body).to be_blank
        end
      end
    end

    %w[api_entreprise api_particulier api_impot_particulier_sandbox].each do |api_type|
      context "when using #{api_type}" do
        let(:authorization_request) { create(:authorization_request, api_type.to_sym, :submitted) }

        it_behaves_like 'submit notification behavior', api_type
      end
    end
  end

  describe '#reopening_submit' do
    subject(:mail) do
      described_class.with(authorization_request:).reopening_submit
    end

    shared_examples 'reopening submit notification behavior' do |api_type|
      let(:notification_setting) do
        case api_type
        when 'api_particulier'
          { instruction_submit_notifications_for_api_particulier: true }
        when 'api_impot_particulier_sandbox'
          { instruction_submit_notifications_for_api_impot_particulier_sandbox: true }
        else
          { instruction_submit_notifications_for_api_entreprise: true }
        end
      end

      context 'when there are instructors to notify' do
        let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: [api_type]) }
        let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: [api_type], **notification_setting) }

        it 'sends the email to instructors and reporters' do
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

    %w[api_entreprise api_impot_particulier_sandbox].each do |api_type|
      context "when using #{api_type}" do
        let(:authorization_request) { create(:authorization_request, api_type.to_sym, :submitted) }

        it_behaves_like 'reopening submit notification behavior', api_type
      end
    end
  end
end
