RSpec.describe NewAuthorizationRequest do
  describe '.facade' do
    subject(:facade) { described_class.facade(scope:) }

    let(:scope) { 'api-entreprise' }

    context 'when the scope is api-entreprise' do
      it 'returns an APIEntreprise facade' do
        expect(facade).to eq NewAuthorizationRequest::APIEntrepriseFacade
      end
    end

    context 'when the scope is something else' do
      let(:scope) { 'other' }

      it 'returns a default facade' do
        expect(described_class.facade(scope: 'other')).to eq NewAuthorizationRequest::DefaultFacade
      end
    end
  end
end
