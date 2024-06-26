RSpec.describe HubEECertDCBridge do
  describe '#perform' do
    subject(:hubee_cert_dc_bridge) { described_class.new(authorization_request).perform }

    let(:authorization_request) { create(:authorization_request) }
    let(:hubee_organization_payload) { { 'id' => '1' } }
    let(:hubee_subscription_payload) { { 'id' => '2' } }
    let(:hubee_api_client) { double('HubEEAPIClient') }

    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive(:get_organization).and_return(hubee_organization_payload)
      allow(hubee_api_client).to receive(:create_subscription).and_return(hubee_subscription_payload)
    end

    it 'calls the HubEE API client to get the organization' do
      expect(hubee_api_client).to receive(:get_organization).with(authorization_request.organization.siret)

      hubee_cert_dc_bridge
    end

    it 'calls the HubEE API client to create a subscription with the hubee organization payload and the valid process code' do
      expect(hubee_api_client).to receive(:create_subscription).with(hubee_organization_payload, 'CERTDC')

      hubee_cert_dc_bridge
    end

    it 'updates the authorization request with the linked token manager id from subscription payload' do
      hubee_cert_dc_bridge

      expect(authorization_request.reload.linked_token_manager_id).to eq('2')
    end
  end
end
