RSpec.describe HubEECertDCBridge do
  describe '#perform on approve' do
    subject(:hubee_cert_dc_bridge) { described_class.new.perform(authorization_request, 'approve') }

    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
    let(:organization) { create(:organization, siret: '21920023500014') }

    let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
    let(:subscription_response) { build(:hubee_subscription_response_payload, id: hubee_subscription_id) }
    let(:hubee_subscription_id) { '1234567890' }

    include_examples 'with mocked hubee API client'
    include_examples 'organization creation in hubee on approve'

    describe 'subscription creation' do
      context 'when client works' do
        it 'does create a subscription on HubEE linked to DataPass ID and CERTDC process code' do
          expect(hubee_api_client).to receive(:create_subscription).with(
            hash_including(
              datapassId: authorization_request.id,
              processCode: 'CERTDC'
            )
          )

          hubee_cert_dc_bridge
        end

        it 'sends the data to create a local administrator in HubEE' do
          expect(hubee_api_client).to receive(:create_subscription).with(
            hash_including(
              localAdministrator: {
                email: 'jean.dupont.administrateur_metier@gouv.fr',
                firstName: 'Jean Administrateur metier',
                lastName: 'Dupont Administrateur metier',
                function: 'Agent Administrateur metier',
                phoneNumber: '0836656565',
              }
            )
          )

          hubee_cert_dc_bridge
        end

        it 'updates external_provider_id to HubEE subscription ID' do
          hubee_cert_dc_bridge

          expect(authorization_request.reload.external_provider_id).to eq(hubee_subscription_id)
        end
      end

      context 'when client raises an HubEEAPIClient::AlreadyExistsError' do
        before do
          allow(hubee_api_client).to receive(:create_subscription).and_raise(HubEEAPIClient::AlreadyExistsError)
        end

        context 'when it is a reopening' do
          let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :reopened, organization:) }

          it 'does not raise an error' do
            expect { hubee_cert_dc_bridge }.not_to raise_error
          end
        end
      end
    end
  end
end
