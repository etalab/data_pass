RSpec.describe AuthorizationRequest::APIParticulierDemarcheNumerique do
  subject(:authorization_request) { build(:authorization_request, :api_particulier_demarche_numerique) }

  describe 'basic infos attributes' do
    it 'exposes intitule, description and volumetrie' do
      expect(authorization_request).to respond_to(:intitule, :description, :volumetrie_approximative)
    end

    it 'does not expose the other API Particulier basic infos attributes' do
      expect(authorization_request).not_to respond_to(:date_prevue_mise_en_production)
      expect(authorization_request).not_to respond_to(:maquette_projet)
    end
  end

  describe 'modalities' do
    it 'does not support modalities' do
      expect(authorization_request).not_to respond_to(:modalities)
    end
  end

  describe 'contacts' do
    it 'keeps the same contacts as API Particulier but without the contact technique' do
      expect(described_class.contact_types.map(&:to_s)).to contain_exactly(
        'contact_metier',
        'delegue_protection_donnees'
      )
    end
  end

  describe 'definition' do
    subject(:definition) { described_class.definition }

    it 'reuses the API Particulier scopes without the FranceConnect ones' do
      api_particulier_scopes = AuthorizationRequest::APIParticulier.definition.scopes
      france_connect_values = api_particulier_scopes.select { |scope| scope.group == 'FranceConnect' }.map(&:value)
      expected_values = api_particulier_scopes.map(&:value) - france_connect_values

      expect(definition.scopes.map(&:value)).to eq(expected_values)
    end

    it 'does not expose any FranceConnect scope' do
      expect(definition.scopes.map(&:group)).not_to include('FranceConnect')
    end

    it 'does not expose the modalities block' do
      expect(definition.blocks.pluck(:name)).not_to include('modalities')
    end
  end
end
