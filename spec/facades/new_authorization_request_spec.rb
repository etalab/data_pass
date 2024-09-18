RSpec.describe NewAuthorizationRequest do
  describe '.facade' do
    subject(:facade) { described_class.facade(definition_id:) }

    let(:definition_id) { 'api_entreprise' }

    context 'when the definition_id is api-entreprise' do
      it 'returns an APIEntreprise facade' do
        expect(facade).to eq NewAuthorizationRequest::APIEntrepriseFacade
      end
    end

    context 'when the definition_id is something else' do
      let(:definition_id) { 'other' }

      it 'returns a default facade' do
        expect(described_class.facade(definition_id: 'other')).to eq NewAuthorizationRequest::DefaultFacade
      end
    end
  end
end
