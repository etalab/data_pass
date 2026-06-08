# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPerimeterDeriver do
  subject(:deriver) { described_class.new(organization, client:) }

  let(:client) { instance_double(GeoAPIGouvClient) }

  def organization_with(categorie:, commune: '69123')
    etablissement = { 'uniteLegale' => { 'categorieJuridiqueUniteLegale' => categorie } }
    etablissement['adresseEtablissement'] = { 'codeCommuneEtablissement' => commune } if commune
    build(:organization, insee_payload: { 'etablissement' => etablissement })
  end

  context 'when the organization is a commune (7210)' do
    let(:organization) { organization_with(categorie: '7210', commune: '69123') }

    it 'returns the establishment commune as the entity without a geo lookup' do
      expect(client).not_to receive(:commune)
      expect(deriver.call).to eq(entity_type: 'commune', code_insee_entity: '69123')
    end
  end

  context 'when the organization is a departement (7220)' do
    let(:organization) { organization_with(categorie: '7220', commune: '69123') }

    before do
      allow(client).to receive(:commune).with('69123')
        .and_return(code: '69123', nom: 'Lyon', code_departement: '69', code_region: '84')
    end

    it 'resolves the department from the establishment commune' do
      expect(deriver.call).to eq(entity_type: 'departement', code_insee_entity: '69')
    end
  end

  context 'when the organization is a region (7230)' do
    let(:organization) { organization_with(categorie: '7230', commune: '69123') }

    before do
      allow(client).to receive(:commune).with('69123')
        .and_return(code: '69123', nom: 'Lyon', code_departement: '69', code_region: '84')
    end

    it 'resolves the region from the establishment commune' do
      expect(deriver.call).to eq(entity_type: 'region', code_insee_entity: '84')
    end
  end

  context 'when the organization is other (7340)' do
    let(:organization) { organization_with(categorie: '7340') }

    it 'returns nil (manual mode)' do
      expect(deriver.call).to be_nil
    end
  end

  context 'when the establishment has no commune code (degraded)' do
    let(:organization) { organization_with(categorie: '7220', commune: nil) }

    it 'returns nil (falls back to manual mode)' do
      expect(deriver.call).to be_nil
    end
  end
end
