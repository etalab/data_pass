RSpec.describe WebhookSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { webhook_serializer.serializable_hash }

    let(:webhook_serializer) { described_class.new(authorization_request, 'whatever') }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    before do
      create(:authorization_request_event, :approve, entity: authorization_request.reload.latest_authorization)
    end

    it 'contains valid keys/values' do
      expect(serializable_hash).to include(
        event: 'whatever',
        model_type: 'enrollment/api_entreprise'
      )

      event = serializable_hash[:data][:pass][:events].first

      expect(event).to be_present
      expect(event[:user]).to be_present
    end
  end
end
