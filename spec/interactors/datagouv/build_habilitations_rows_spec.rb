# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Datagouv::BuildHabilitationsRows do
  subject(:result) { described_class.call }

  let!(:organization) { create(:organization, siret: '21920023500014') }
  let!(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, organization:) }
  let!(:active_authorization) { authorization_request.reload.latest_authorization }

  before do
    active_authorization.update!(data: active_authorization.data.merge('scopes' => 'dummy_scope', 'cadre_juridique_nature' => 'Loi'))
  end

  it 'succeeds' do
    expect(result).to be_success
  end

  it 'returns one row per active authorization' do
    expect(result.rows.size).to eq(1)
  end

  it 'includes API/service, denomination, siret, données demandées, fournisseur, cadre juridique et date de validation' do
    row = result.rows.first

    expect(row[0]).to eq('APIEntreprise')
    expect(row[2]).to eq('21920023500014')
    expect(row[3]).to eq('dummy_scope')
    expect(row[5]).to eq('Loi')
    expect(row[6]).to eq(active_authorization.created_at.strftime('%Y-%m-%d'))
  end

  context 'when an authorization is obsolete' do
    before do
      active_authorization.deprecate!
    end

    it 'returns only active authorizations' do
      expect(result.rows.size).to eq(0)
    end
  end
end
