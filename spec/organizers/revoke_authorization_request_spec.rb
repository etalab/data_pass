RSpec.describe RevokeAuthorizationRequest, type: :organizer do
  describe '.call' do
    subject(:revoke_authorization_request) { described_class.call(authorization_request:, revocation_of_authorization_params:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }

    context 'with valid params' do
      let(:revocation_of_authorization_params) { attributes_for(:revocation_of_authorization) }

      context 'with authorization request in validated state' do
        let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

        it { is_expected.to be_success }

        it 'creates a revocation of authorization' do
          expect { revoke_authorization_request }.to change(RevocationOfAuthorization, :count).by(1)
        end

        it 'changes state to revoked' do
          expect { revoke_authorization_request }.to change { authorization_request.reload.state }.from('validated').to('revoked')
        end

        it 'delivers an email' do
          expect { revoke_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :revoke)
        end

        context 'when there is a bridge' do
          let(:authorization_request_kind) { :hubee_cert_dc }

          before do
            allow(HubEECertDCBridge).to receive(:perform_later)
          end

          it 'executes the bridge asynchronously with revoke event' do
            revoke_authorization_request

            expect(HubEECertDCBridge).to have_received(:perform_later).with(authorization_request, :revoke)
          end
        end
      end

      context 'with authorization request in draft state' do
        let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { revoke_authorization_request }.not_to change { authorization_request.reload.state }
        end
      end
    end
  end
end
