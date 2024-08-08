RSpec.describe HubEECertDCBridge do
  subject(:hubee_cert_dc_bridge) { described_class.new(authorization_request).perform }

  let(:hubee_api_client) { instance_double(HubEEAPIClient) }

  let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
  let(:organization) { create(:organization, siret: '21920023500014') }

  let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
  let(:subscription_response) { build(:hubee_subscription_response_payload, :cert_dc) }

  before do
    allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
    allow(hubee_api_client).to receive_messages(
      get_organization: organization_payload.with_indifferent_access,
      create_organization: organization_payload.with_indifferent_access,
      create_subscription: subscription_response.with_indifferent_access
    )
  end

  describe '#perform' do
    let(:bridge) { described_class.new(authorization_request) }

    before do
      allow(bridge).to receive(:find_or_create_organization).and_call_original
    end

    it 'does not render en error' do
      expect { hubee_cert_dc_bridge }.not_to raise_error
    end

    it 'Finds or creates organization' do
      expect(bridge).to receive(:find_or_create_organization)

      bridge.perform
    end

    it 'Creates and store subscription id' do
      expect(bridge).to receive(:create_and_store_subscription).with(organization_payload.with_indifferent_access)

      bridge.perform
    end
  end

  describe '#find_or_create_organization' do
    context 'when organization exists' do
      it 'gets the organization and return an organization payload' do
        siret = authorization_request.organization.siret
        code_commune = authorization_request.organization.code_commune

        expect(hubee_api_client).to receive(:get_organization).with(siret, code_commune)

        hubee_cert_dc_bridge
      end
    end

    context 'when organization does not exists' do
      before do
        allow(hubee_api_client).to receive(:get_organization).and_raise(Faraday::ResourceNotFound)
        allow(hubee_api_client).to receive(:create_organization).with(organization_payload).and_return(organization_payload)
      end

      it 'calls create_organization' do
        expect(hubee_api_client).to receive(:create_organization).with(organization_payload.deep_symbolize_keys)

        hubee_cert_dc_bridge
      end
    end
  end

  describe '#create_and_store_subscription' do
    let(:subscription_payload) { build(:hubee_subscription_payload, :cert_dc, authorization_request:, organization:) }

    it 'Creates a subscription to hubee and return a subscription_id' do
      expect(hubee_api_client).to receive(:create_subscription).with(subscription_payload.deep_symbolize_keys)

      hubee_cert_dc_bridge
    end

    it 'Updates the authorization request with the linked token manager id from subscription payload' do
      hubee_cert_dc_bridge

      expect(authorization_request.reload.linked_token_manager_id).to eq('22')
    end
  end
end
