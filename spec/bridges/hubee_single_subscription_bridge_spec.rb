RSpec.describe HubEESingleSubscriptionBridge do
  subject(:bridge) { bridge_class.new.perform(authorization_request, 'approve') }

  let(:bridge_class) { HubEEImpayesLoyerBridge }
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }
  let(:subscription_response) { build(:hubee_subscription_response_payload, id: 'unused') }
  let(:existing_subscription_id) { 'existing-sub-id-123' }
  let(:existing_subscriptions) do
    [
      { 'id' => 'other-process-sub-id', 'processCode' => 'CERTDC', 'datapassId' => authorization_request.id },
      { 'id' => existing_subscription_id, 'processCode' => 'SIMPLO', 'datapassId' => authorization_request.id }
    ]
  end

  include_context 'with mocked hubee API client'

  before do
    allow(hubee_api_client).to receive(:create_subscription).and_raise(HubEEAPIClient::AlreadyExistsError)
    allow(hubee_api_client).to receive(:find_subscriptions).and_return(existing_subscriptions.map(&:with_indifferent_access))
    allow(Sentry).to receive(:capture_message)
  end

  context 'with a first validation and a subscription already existing in HubEE' do
    let(:authorization_request) { create(:authorization_request, :hubee_impayes_loyer, :validated, organization:, external_provider_id: nil) }

    it 'stores the ID of the existing subscription matching the process code' do
      bridge

      expect(authorization_request.reload.external_provider_id).to eq(existing_subscription_id)
    end

    it 'fetches the subscriptions linked to the DataPass ID' do
      bridge

      expect(hubee_api_client).to have_received(:find_subscriptions).with(datapassId: authorization_request.id)
    end

    it 'sends a warning to Sentry' do
      bridge

      expect(Sentry).to have_received(:capture_message).with(
        "HubEE subscription already exists for authorization_request ##{authorization_request.id}",
        level: :warning,
        extra: { subscription_id: existing_subscription_id }
      )
    end

    context 'when the subscription is not found in HubEE' do
      before { allow(hubee_api_client).to receive(:find_subscriptions).and_return([]) }

      it 'raises an error' do
        expect { bridge }.to raise_error(RuntimeError, /HubEE subscription should exist but was not found/)
      end
    end
  end

  context 'with a reopening whose subscription ID is already stored' do
    let(:authorization_request) { create(:authorization_request, :hubee_impayes_loyer, :reopened, organization:, external_provider_id: 'stored-id') }

    it 'keeps the stored ID without calling HubEE again' do
      bridge

      expect(authorization_request.reload.external_provider_id).to eq('stored-id')
      expect(hubee_api_client).not_to have_received(:find_subscriptions)
    end
  end

  context 'with the CertDC bridge' do
    let(:bridge_class) { HubEECertDCBridge }
    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:, external_provider_id: nil) }
    let(:existing_subscription_id) { 'certdc-sub-id' }
    let(:existing_subscriptions) do
      [{ 'id' => existing_subscription_id, 'processCode' => 'CERTDC', 'datapassId' => authorization_request.id }]
    end

    it 'recovers the CERTDC subscription' do
      bridge

      expect(authorization_request.reload.external_provider_id).to eq(existing_subscription_id)
    end
  end
end
