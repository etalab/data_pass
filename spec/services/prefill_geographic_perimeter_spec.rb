# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PrefillGeographicPerimeter do
  let(:habilitation_type) { create(:habilitation_type, blocks: [{ 'name' => 'cnous_data_extraction_criteria' }]) }
  let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }

  def organization_with(categorie:, commune: '69123')
    etablissement = { 'uniteLegale' => { 'categorieJuridiqueUniteLegale' => categorie } }
    etablissement['adresseEtablissement'] = { 'codeCommuneEtablissement' => commune } if commune
    create(:organization, insee_payload: { 'etablissement' => etablissement })
  end

  def persisted_request(organization:)
    klass.new(organization:, applicant: create(:user), form_uid: habilitation_type.uid)
      .tap { |request| request.save(validate: false) }
  end

  def stub_geo_commune(code, departement:, region:)
    stub_request(:get, "https://geo.api.gouv.fr/communes/#{code}?fields=nom,codeDepartement,codeRegion")
      .to_return(
        status: 200,
        body: { 'code' => code, 'nom' => 'X', 'codeDepartement' => departement, 'codeRegion' => region }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'is idempotent: skips derivation when an entity is already stored' do
    request = persisted_request(organization: organization_with(categorie: '7210', commune: '92023'))

    described_class.new(request).call

    expect(request.reload.code_insee_entity).to eq('92023')
    expect(a_request(:get, /geo\.api\.gouv\.fr/)).not_to have_been_made
  end

  it 'stores the region derived via geo' do
    stub_geo_commune('69123', departement: '69', region: '84')
    request = persisted_request(organization: organization_with(categorie: '7230', commune: '69123'))

    expect(request.reload.geographic_perimeter_declaration).to eq(type: 'region', code: '84')
  end

  it 'does nothing without an organization' do
    request = klass.new(applicant: create(:user), form_uid: habilitation_type.uid)

    described_class.new(request).call

    expect(request.entity_type).to be_nil
    expect(a_request(:get, /geo\.api\.gouv\.fr/)).not_to have_been_made
  end

  it 'swallows a geo timeout and leaves the perimeter empty' do
    stub_request(:get, %r{https://geo\.api\.gouv\.fr/communes/69123}).to_timeout
    request = persisted_request(organization: organization_with(categorie: '7220', commune: '69123'))

    expect(request.reload.entity_type).to be_nil
  end
end
