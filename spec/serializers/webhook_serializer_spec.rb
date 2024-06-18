RSpec.describe WebhookSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { webhook_serializer.serializable_hash }

    let(:webhook_serializer) { described_class.new(authorization_request, 'whatever') }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'contains valid keys/values' do
      expect(serializable_hash).to include(
        event: 'whatever',
        model_type: 'authorization_request/api_entreprise',
      )

      expect(serializable_hash[:data]).to be_a(Hash)
      expect(serializable_hash[:data][:state]).to eq('validated')
      expect(serializable_hash[:data][:data][:intitule]).to eq(authorization_request.intitule)

      expect(serializable_hash[:data][:applicant]).to be_a(Hash)
      expect(serializable_hash[:data][:applicant][:id]).to eq(authorization_request.applicant_id)

      expect(serializable_hash[:data][:organization]).to be_a(Hash)
      expect(serializable_hash[:data][:organization][:siret]).to eq(authorization_request.organization.siret)
    end
  end
end
