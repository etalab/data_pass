RSpec.describe HubEECertDCBridge do
  subject(:hubee_cert_dc_bridge) { described_class.new(authorization_request).perform }

  let(:hubee_api_client) { instance_double(HubEEAPIClient) }

  let(:authorization_request) { create(:authorization_request, id: 2, organization_id: organization.id, data: authorization_request_data, last_validated_at: 'Thu, 18 Jul 2024 14:00:55.500378000 CEST +02:00', updated_at: 'Thu, 18 Jul 2024 14:00:55.500378000 CEST +02:00', linked_token_manager_id: nil) }
  let(:authorization_request_data) { { 'administrateur_metier_email' => 'admin@yopmail.com', 'administrateur_metier_phone_number' => '01.23.45.67.89' } }

  let(:organization) { create(:organization, id: 3, siret: '21920023500014') }

  let(:process_code) { 'CERTDC' }

  before do
    allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
    allow(hubee_api_client).to receive_messages(get_organization: organization_payload.with_indifferent_access, create_subscription: subscription_response.with_indifferent_access)
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
      expect(bridge).to receive(:find_or_create_organization).with(authorization_request)

      bridge.perform
    end

    it 'Create a subscription to hubee with a subscription_body_payload and return a subscription_id' do
      expect(hubee_api_client).to receive(:create_subscription).with(subscription_body_payload(process_code))

      hubee_cert_dc_bridge
    end

    it 'Updates the authorization request with the linked token manager id from subscription payload' do
      hubee_cert_dc_bridge

      expect(authorization_request.reload.linked_token_manager_id).to eq('22')
    end
  end

  describe '#find_or_create_organization' do
    context 'when organization exists it calls the hubee API client' do
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

      it 'calls get_organization but returns a Faraday::ResourceNotFound' do
        expect(hubee_api_client).to receive(:create_organization).with(organization_payload)

        hubee_cert_dc_bridge
      end
    end
  end
end
