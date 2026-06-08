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

  def build_request(organization:, **attrs)
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

  describe '#entity_type / #code_insee_entity (inferred from the organization)' do
    it 'infers a commune entity without a geo lookup' do
      request = build_request(organization: organization_with(categorie: '7210', commune: '92023'))

      expect(request.entity_type).to eq('commune')
      expect(request.code_insee_entity).to eq('92023')
    end

    it 'infers a departement entity via geo' do
      stub_geo_commune('69123', departement: '69', region: '84')
      request = build_request(organization: organization_with(categorie: '7220', commune: '69123'))

      expect(request.entity_type).to eq('departement')
      expect(request.code_insee_entity).to eq('69')
    end

    it 'infers a region entity via geo' do
      stub_geo_commune('69123', departement: '69', region: '84')
      request = build_request(organization: organization_with(categorie: '7230', commune: '69123'))

      expect(request.entity_type).to eq('region')
      expect(request.code_insee_entity).to eq('84')
    end

    it 'has no entity for an other-category organization (manual mode)' do
      request = build_request(organization: organization_with(categorie: '7340'))

      expect(request.entity_type).to be_nil
      expect(request.code_insee_entity).to be_nil
    end

    it 'degrades to no entity when geo is unreachable' do
      stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/69400}).to_return(status: 502, body: '')
      request = build_request(organization: organization_with(categorie: '7220', commune: '69400'))

      expect(request.code_insee_entity).to be_nil
    end
  end

  describe '#geographic_perimeter' do
    it 'unions the inferred entity with the manually added communes' do
      stub_geo_commune('69123', departement: '69', region: '84')
      request = build_request(
        organization: organization_with(categorie: '7220', commune: '69123'),
        manual_code_insee_communes: %w[75056]
      )

      expect(request.geographic_perimeter).to contain_exactly('69', '75056')
    end
  end

  describe '#geographic_perimeter_automatic?' do
    it 'is true for a commune-level organization' do
      request = build_request(organization: organization_with(categorie: '7210', commune: '92023'))

      expect(request).to be_geographic_perimeter_automatic
    end

    it 'is false for an other-category organization (manual mode)' do
      request = build_request(organization: organization_with(categorie: '7340'), manual_code_insee_communes: %w[92023])

      expect(request).not_to be_geographic_perimeter_automatic
    end

    it 'is false when the entity could not be inferred (degraded)' do
      stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/69401}).to_return(status: 502, body: '')
      request = build_request(organization: organization_with(categorie: '7220', commune: '69401'))

      expect(request).not_to be_geographic_perimeter_automatic
    end
  end

  describe '#geographic_perimeter_declaration' do
    it 'exposes the inferred commune level and code' do
      request = build_request(organization: organization_with(categorie: '7210', commune: '92023'))

      expect(request.geographic_perimeter_declaration).to eq(type: 'commune', code: '92023')
    end

    it 'is nil for a manual-mode organization' do
      request = build_request(organization: organization_with(categorie: '7340'), manual_code_insee_communes: %w[92023])

      expect(request.geographic_perimeter_declaration).to be_nil
    end
  end
end
