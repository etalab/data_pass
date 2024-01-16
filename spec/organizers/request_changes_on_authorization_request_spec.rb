RSpec.describe RequestChangesOnAuthorizationRequest do
  describe '.call' do
    subject(:request_changes_authorization_request) { described_class.call(instructor_modification_request_params:, authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }

    context 'with valid params' do
      let(:instructor_modification_request_params) { attributes_for(:instructor_modification_request) }

      context 'with authorization request in submitted state' do
        let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :submitted) }

        it { is_expected.to be_success }

        it 'creates an instructor modification request' do
          expect { request_changes_authorization_request }.to change(InstructorModificationRequest, :count).by(1)
        end

        it 'changes state to request_changes' do
          expect { request_changes_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('changes_requested')
        end

        it 'delivers an email' do
          expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :changes_requested)
        end

        include_examples 'creates an event', event_name: :request_changes, entity_type: :instructor_modification_request
      end

      context 'with authorization request in draft state' do
        let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { request_changes_authorization_request }.not_to change { authorization_request.reload.state }
        end
      end
    end

    context 'with invalid params' do
      let(:instructor_modification_request_params) { attributes_for(:instructor_modification_request, reason: nil) }
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :submitted) }

      it { is_expected.to be_failure }

      it 'does not create an instructor modification request' do
        expect { request_changes_authorization_request }.not_to change(InstructorModificationRequest, :count)
      end

      it 'does not change state' do
        expect { request_changes_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
