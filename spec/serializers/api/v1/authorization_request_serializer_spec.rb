RSpec.describe API::V1::AuthorizationRequestSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, :validated) }

    it 'includes the authorization request attributes' do
      expect(serializable_hash).to include(
        id: authorization_request.id,
        public_id: authorization_request.public_id,
        type: authorization_request.type,
        state: authorization_request.state,
        form_uid: authorization_request.form_uid,
        created_at: authorization_request.created_at,
        last_submitted_at: authorization_request.last_submitted_at,
        last_validated_at: authorization_request.last_validated_at,
        reopening: authorization_request.reopening?,
        reopened_at: authorization_request.reopened_at,
        data: authorization_request.data,
      )
    end

    it 'includes the organization' do
      expect(serializable_hash).to have_key(:organisation)
      expect(serializable_hash[:organisation]).to include(
        id: authorization_request.organization.id,
        siret: authorization_request.organization.siret,
        insee_payload: authorization_request.organization.insee_payload
      )
    end
  end

  describe 'geographic perimeter contract (relais)' do
    subject(:data) { described_class.new(authorization_request).serializable_hash[:data] }

    let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'cnous_data_extraction_criteria' }]) }
    let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
    let(:organization) do
      etablissement = {
        'uniteLegale' => { 'categorieJuridiqueUniteLegale' => '7220' },
        'adresseEtablissement' => { 'codeCommuneEtablissement' => '69123' }
      }
      create(:organization, insee_payload: { 'etablissement' => etablissement })
    end
    let(:authorization_request) do
      klass.new(
        organization:,
        applicant: create(:user),
        form_uid: habilitation_type.uid,
        manual_code_insee_communes: %w[75056]
      ).tap { |request| request.save(validate: false) }.reload
    end

    before do
      stub_request(:get, 'https://geo.api.gouv.fr/communes/69123?fields=nom,codeDepartement,codeRegion')
        .to_return(
          status: 200,
          body: { 'code' => '69123', 'nom' => 'Lyon', 'codeDepartement' => '69', 'codeRegion' => '84' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'exposes the inferred entity and the manually added communes' do
      expect(data['entity_type']).to eq('departement')
      expect(data['code_insee_entity']).to eq('69')
      expect(JSON.parse(data['manual_code_insee_communes'])).to eq(%w[75056])
    end
  end
end
