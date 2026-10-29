RSpec.describe NamespacedMetadata do
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe '#metadata_for' do
    it 'returns an empty hash when the namespace is absent' do
      expect(authorization_request.metadata_for(:api)).to eq({})
    end
  end

  describe '#assign_metadata' do
    before do
      authorization_request.update!(metadata: { 'datapass' => { 'lot' => 'migration' } })
    end

    it 'writes the namespace without touching the other ones' do
      authorization_request.assign_metadata(:api, { campagne: 'migration-editeur-x' })
      authorization_request.save!

      expect(authorization_request.reload.metadata).to eq(
        'datapass' => { 'lot' => 'migration' },
        'api' => { 'campagne' => 'migration-editeur-x' }
      )
    end

    it 'replaces the whole namespace content' do
      authorization_request.assign_metadata(:datapass, { 'campagne' => 'reprise' })

      expect(authorization_request.metadata_for(:datapass)).to eq('campagne' => 'reprise')
    end

    it 'removes the namespace when given nil or an empty hash' do
      authorization_request.assign_metadata(:datapass, nil)

      expect(authorization_request.metadata).to eq({})
    end
  end

  describe 'validation' do
    it 'refuses to save invalid metadata, with a readable message' do
      authorization_request.assign_metadata(:api, { 'commentaire' => 'v' * 501 })

      expect(authorization_request.save).to be(false)
      expect(authorization_request.errors.full_messages).to include('Les métadonnées de l’espace « api » : la valeur de « commentaire » dépasse 500 caractères.')
    end

    it 'refuses an unknown namespace' do
      authorization_request.assign_metadata(:inconnu, { 'source' => 'api' })

      expect(authorization_request).not_to be_valid
      expect(authorization_request.errors.full_messages).to include('Les métadonnées utilisent un espace inconnu : « inconnu ».')
    end

    it 'names the namespace and the limit in the message' do
      authorization_request.assign_metadata(:datapass, (1..21).to_h { |index| ["cle_#{index}", 'v'] })

      expect(authorization_request).not_to be_valid
      expect(authorization_request.errors.full_messages).to include('Les métadonnées de l’espace « datapass » dépassent 20 clés.')
    end
  end
end
