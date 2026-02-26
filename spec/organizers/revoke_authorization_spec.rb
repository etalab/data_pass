RSpec.describe RevokeAuthorization, type: :organizer do
  describe '.call' do
    subject(:revoke_authorization) do
      described_class.call(
        authorization:,
        revocation_of_authorization_params:,
        user:
      )
    end

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }
    let(:revocation_of_authorization_params) { attributes_for(:revocation_of_authorization) }

    context 'with an active authorization on a validated request' do
      let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }
      let!(:authorization) { authorization_request.latest_authorization }

      it { is_expected.to be_success }

      it_behaves_like 'creates an event', event_name: :revoke, entity_type: :revocation_of_authorization

      it 'creates a revocation of authorization linked to the authorization' do
        expect { revoke_authorization }.to change(RevocationOfAuthorization, :count).by(1)

        expect(RevocationOfAuthorization.last.authorization).to eq(authorization)
      end

      it 'revokes the authorization' do
        expect { revoke_authorization }.to change { authorization.reload.state }.from('active').to('revoked')
      end

      it 'delivers an email' do
        expect { revoke_authorization }.to have_enqueued_mail(AuthorizationRequestMailer, :revoke)
      end

      context 'when there is a bridge' do
        before do
          allow(HubEECertDCBridge).to receive(:perform_later)
        end

        it 'executes the bridge asynchronously with revoke event' do
          revoke_authorization

          expect(HubEECertDCBridge).to have_received(:perform_later).with(authorization_request, :revoke)
        end
      end

      context 'when the request has multiple active authorizations' do
        let!(:sister_authorization) do
          create(:authorization, request: authorization_request, applicant: authorization_request.applicant)
        end

        it 'does not revoke sister authorizations' do
          revoke_authorization

          expect(sister_authorization.reload.state).to eq('active')
        end

        it 'does not revoke the authorization request' do
          expect { revoke_authorization }.not_to change { authorization_request.reload.state }
        end
      end

      context 'when all authorizations become revoked' do
        it 'transitions the authorization request to revoked' do
          expect { revoke_authorization }.to change { authorization_request.reload.state }.from('validated').to('revoked')
        end
      end

      context 'when there are obsolete authorizations and the last active one is revoked' do
        before do
          create(:authorization, request: authorization_request, applicant: authorization_request.applicant).tap(&:deprecate!)
        end

        it 'transitions the authorization request to revoked' do
          expect { revoke_authorization }.to change { authorization_request.reload.state }.from('validated').to('revoked')
        end
      end
    end
  end
end
