# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizationExtensions::CnousDataExtractionCriteria do
  let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'cnous_data_extraction_criteria' }]) }
  let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }

  def organization_with(categorie:, commune: '92023')
    etablissement = { 'uniteLegale' => { 'categorieJuridiqueUniteLegale' => categorie } }
    etablissement['adresseEtablissement'] = { 'codeCommuneEtablissement' => commune } if commune
    create(:organization, insee_payload: { 'etablissement' => etablissement })
  end

  def build_request(organization: organization_with(categorie: '7340'), **attrs)
    klass.new(organization:, applicant: create(:user), form_uid: habilitation_type.uid, **attrs)
  end

  def stub_geo_commune(code, departement:, region:)
    stub_request(:get, "https://geo.api.gouv.fr/communes/#{code}?fields=nom,codeDepartement,codeRegion")
      .to_return(
        status: 200,
        body: { 'code' => code, 'nom' => 'X', 'codeDepartement' => departement, 'codeRegion' => region }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'mass-assignment safety' do
    it 'does not expose entity_type / code_insee_entity as permitted extra attributes' do
      expect(klass.extra_attributes).not_to include(:entity_type, :code_insee_entity)
    end
  end

  describe '#entity_type / #code_insee_entity' do
    it 'reads the stored geographic identity' do
      request = build_request(data: { 'entity_type' => 'commune', 'code_insee_entity' => '92023' })

      expect(request.entity_type).to eq('commune')
      expect(request.code_insee_entity).to eq('92023')
    end

    it 'is nil when no entity has been stored' do
      request = build_request

      expect(request.entity_type).to be_nil
      expect(request.code_insee_entity).to be_nil
    end
  end

  describe '#geographic_perimeter_automatic?' do
    it 'is true once an entity has been stored' do
      request = build_request(data: { 'entity_type' => 'commune', 'code_insee_entity' => '92023' })

      expect(request).to be_geographic_perimeter_automatic
    end

    it 'is false in manual mode (no stored entity)' do
      request = build_request(manual_code_insee_communes: %w[92023])

      expect(request).not_to be_geographic_perimeter_automatic
    end
  end

  describe 'populate codes insee and entity on create (after_commit)' do
    it 'stores a commune entity without a geo lookup' do
      request = build_request(organization: organization_with(categorie: '7210', commune: '92023'))
      request.save(validate: false)

      expect(request.reload.data).to include('entity_type' => 'commune', 'code_insee_entity' => '92023')
      expect(a_request(:get, /geo\.api\.gouv\.fr/)).not_to have_been_made
    end

    it 'stores a departement entity derived via geo' do
      stub_geo_commune('69123', departement: '69', region: '84')
      request = build_request(organization: organization_with(categorie: '7220', commune: '69123'))
      request.save(validate: false)

      expect(request.reload.data).to include('entity_type' => 'departement', 'code_insee_entity' => '69')
    end

    it 'stores a region entity derived via geo' do
      stub_geo_commune('69123', departement: '69', region: '84')
      request = build_request(organization: organization_with(categorie: '7230', commune: '69123'))
      request.save(validate: false)

      expect(request.reload.data).to include('entity_type' => 'region', 'code_insee_entity' => '84')
    end

    it 'stays in manual mode for an other-category organization' do
      request = build_request(organization: organization_with(categorie: '7340'))
      request.save(validate: false)

      expect(request.reload.geographic_perimeter_automatic?).to be(false)
    end

    it 'degrades to manual mode when geo is unreachable' do
      stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/69400}).to_return(status: 502, body: '')
      request = build_request(organization: organization_with(categorie: '7220', commune: '69400'))
      request.save(validate: false)

      expect(request.reload.geographic_perimeter_automatic?).to be(false)
    end

    it 'degrades to manual mode when geo times out' do
      stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/69401}).to_timeout
      request = build_request(organization: organization_with(categorie: '7220', commune: '69401'))
      request.save(validate: false)

      expect(request.reload.geographic_perimeter_automatic?).to be(false)
    end
  end
end
