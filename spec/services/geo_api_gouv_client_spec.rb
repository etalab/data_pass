# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeoAPIGouvClient do
  subject(:client) { described_class.new }

  let(:base_url) { 'https://geo.api.gouv.fr' }

  describe '#commune' do
    let(:url) { "#{base_url}/communes/69123?fields=nom,codeDepartement,codeRegion" }

    it 'returns the commune with its name, department and region codes' do
      stub_request(:get, url).to_return(
        status: 200,
        body: { 'code' => '69123', 'nom' => 'Lyon', 'codeDepartement' => '69', 'codeRegion' => '84' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(client.commune('69123')).to eq(
        code: '69123', nom: 'Lyon', code_departement: '69', code_region: '84'
      )
    end

    it 'returns nil for an unknown commune (404)' do
      stub_request(:get, url).to_return(status: 404, body: '')

      expect(client.commune('69123')).to be_nil
    end

    it 'raises ServerError on 5xx' do
      stub_request(:get, url).to_return(status: 502, body: '')

      expect { client.commune('69123') }.to raise_error(GeoAPIGouvClient::ServerError)
    end

    it 'caches the result for 24h (single HTTP call)' do
      stub = stub_request(:get, url).to_return(
        status: 200,
        body: { 'code' => '69123', 'nom' => 'Lyon', 'codeDepartement' => '69', 'codeRegion' => '84' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      2.times { client.commune('69123') }

      expect(stub).to have_been_requested.once
    end
  end
end
