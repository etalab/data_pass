RSpec.describe API::V1::AuthorizationRequestEventSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(event) }
    let(:event) { create(:authorization_request_event) }

    it 'includes the authorization event attributes' do
      expect(serializable_hash).to include(
        id: event.id,
        name: event.name,
        created_at: event.created_at
      )
    end
  end
end
