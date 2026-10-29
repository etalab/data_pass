RSpec.describe AssignAPIMetadataToAuthorizationRequest do
  describe '#call' do
    subject(:result) { described_class.call(authorization_request:, api_metadata:, api_metadata_provided:) }

    let(:authorization_request) do
      create(:authorization_request, :api_entreprise).tap do |request|
        request.update!(metadata: { 'api' => { 'campagne' => 'ancienne' }, 'datapass' => { 'lot' => 'migration' } })
      end
    end
    let(:api_metadata_provided) { true }

    context 'when no metadata were sent' do
      let(:api_metadata_provided) { false }
      let(:api_metadata) { nil }

      it 'leaves metadata untouched' do
        expect { result }.not_to change { authorization_request.reload.metadata }
      end
    end

    context 'with an object' do
      let(:api_metadata) { { 'source' => 'api' } }

      it 'replaces the api namespace only' do
        result

        expect(authorization_request.reload.metadata).to eq('api' => { 'source' => 'api' }, 'datapass' => { 'lot' => 'migration' })
      end
    end

    context 'with null' do
      let(:api_metadata) { nil }

      it 'removes the api namespace only' do
        result

        expect(authorization_request.reload.metadata).to eq('datapass' => { 'lot' => 'migration' })
      end
    end
  end
end
