RSpec.describe ApproveAuthorizationRequest do
  describe '.call' do
    subject(:approve_authorization_request) { described_class.call(authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }

    context 'with authorization request in submitted state' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :submitted) }

      it { is_expected.to be_success }

      it 'changes state to validated' do
        expect { approve_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('validated')
      end

      it 'delivers an email' do
        expect { approve_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :validated)
      end

      include_examples 'creates an event', event_name: :approve

      context 'with authorization request which has a bridge' do
        let(:bridge) { instance_double(APIInfinoeSandboxBridge, perform: true) }
        let(:authorization_request) { create(:authorization_request, :api_infinoe_sandbox, :submitted) }

        before do
          allow(APIInfinoeSandboxBridge).to receive(:new).and_return(bridge)
        end

        it 'triggers the bridge' do
          approve_authorization_request

          expect(bridge).to have_received(:perform)
        end
      end
    end

    context 'with authorization request in draft state' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { approve_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
