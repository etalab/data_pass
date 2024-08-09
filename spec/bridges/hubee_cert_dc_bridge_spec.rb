RSpec.describe HubEECertDCBridge do
  describe '#perform on approve' do
    subject(:hubee_cert_dc_bridge) { described_class.perform_now(authorization_request, 'approve') }

    let(:hubee_api_client) { instance_double(HubEEAPIClient) }

    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
    let(:organization) { create(:organization, siret: '21920023500014') }

    let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
    let(:subscription_response) { build(:hubee_subscription_response_payload, :cert_dc, id: hubee_subscription_id) }
    let(:hubee_subscription_id) { '1234567890' }

    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive_messages(
        create_organization: organization_payload.with_indifferent_access,
        create_subscription: subscription_response.with_indifferent_access
      )
    end

    context 'when organization exists on HubEE' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_return(organization_payload.with_indifferent_access)
      end

      it 'does not create a new organization on HubEE' do
        hubee_cert_dc_bridge

        expect(hubee_api_client).not_to have_received(:create_organization)
      end
    end

    context 'when organization does not exists' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_raise(Faraday::ResourceNotFound)
      end

      it 'calls create_organization' do
        expect(hubee_api_client).to receive(:create_organization).with(organization_payload.deep_symbolize_keys)

        hubee_cert_dc_bridge
      end
    end

    describe 'subscription creation' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_return(organization_payload.with_indifferent_access)
      end

      it 'does create a subscription on HubEE linked to DataPass ID and CERTDC process code' do
        expect(hubee_api_client).to receive(:create_subscription).with(
          hash_including(
            datapassId: authorization_request.id,
            processCode: 'CERTDC'
          )
        )

        hubee_cert_dc_bridge
      end

      it 'updates linked_token_manager_id to HubEE subscription ID' do
        hubee_cert_dc_bridge

        expect(authorization_request.reload.linked_token_manager_id).to eq(hubee_subscription_id)
      end
    end
  end
end
