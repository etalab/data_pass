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
    it 'defaults to the non-modifiable params modality' do
      expect(authorization_request.modalities).to eq(%w[params])
    end

    it 'only allows the params modality' do
      expect(described_class::MODALITIES).to eq(%w[params])
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

    let(:groups_unavailable_through_france_connect) do
      [
        'FranceConnect',
        "API Statut demandeur d'emploi",
        'API Paiements France Travail',
        'API Statut élève scolarisé et boursier',
        'API Statut Sportif de Haut Niveau'
      ]
    end

    it 'reuses the API Particulier scopes retrievable through a FranceConnect identity' do
      api_particulier_scopes = AuthorizationRequest::APIParticulier.definition.scopes
      expected_values = api_particulier_scopes
        .reject { |scope| groups_unavailable_through_france_connect.include?(scope.group) }
        .map(&:value)

      expect(definition.scopes.map(&:value)).to eq(expected_values)
    end

    it 'does not expose scopes that cannot be retrieved through a FranceConnect identity' do
      expect(definition.scopes.map(&:group).uniq).not_to include(*groups_unavailable_through_france_connect)
    end

    it 'exposes the modalities block' do
      expect(definition.blocks.pluck(:name)).to include('modalities')
    end
  end
end
