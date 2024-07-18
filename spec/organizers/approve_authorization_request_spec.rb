RSpec.describe ApproveAuthorizationRequest do
  describe '.call' do
    subject(:approve_authorization_request) { described_class.call(authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

    context 'with authorization request in submitted state' do
      let!(:authorization_request) { create(:authorization_request, :api_particulier, :submitted) }

      it { is_expected.to be_success }

      it 'changes state to validated' do
        expect { approve_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('validated')
      end

      it 'changes last_validated_at' do
        expect { approve_authorization_request }.to change { authorization_request.reload.last_validated_at }
      end

      it 'delivers an email' do
        expect { approve_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :validated)
      end

      context 'when it is a reopening' do
        let!(:authorization_request) { create(:authorization_request, :api_particulier, :reopened) }

        before do
          authorization_request.update!(state: 'submitted')
        end

        it 'delivers an email specific to reopening' do
          expect { approve_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_validated)
        end
      end

      it 'creates a new authorization with snapshoted data' do
        expect { approve_authorization_request }.to change(Authorization, :count).by(1)

        authorization = Authorization.last

        expect(authorization.applicant).to eq(authorization_request.applicant)
        expect(authorization.organization).to eq(authorization_request.organization)
        expect(authorization.request).to eq(authorization_request)
        expect(authorization.data).to eq(authorization_request.data)
      end

      describe 'when there is attached documents' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, documents: %i[cadre_juridique_document]) }

        it 'creates a new authorization with attached documents' do
          expect { approve_authorization_request }.to change(Authorization, :count).by(1)

          authorization = Authorization.last

          expect(authorization.documents.count).to eq(1)
          expect(authorization.documents.first.file.blob).to eq(authorization_request.cadre_juridique_document.blob)
        end
      end

      include_examples 'creates an event', event_name: :approve, entity_type: :authorization

      context 'with authorization request which has a bridge' do
        let(:bridge) { instance_double(APIInfinoeSandboxBridge, perform: true) }
        let!(:authorization_request) { create(:authorization_request, :api_infinoe_sandbox, :submitted) }

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
      let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { approve_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
