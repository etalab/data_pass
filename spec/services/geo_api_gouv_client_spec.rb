# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeoAPIGouvClient do
  subject(:client) { described_class.new }

  let(:url) { 'https://geo.api.gouv.fr/communes/69123?fields=codeDepartement,codeRegion' }

  describe '#get' do
    it 'returns the parsed body on success' do
      stub_request(:get, url).to_return(
        status: 200,
        body: { 'codeDepartement' => '69', 'codeRegion' => '84' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      expect(client.get('/communes/69123', fields: 'codeDepartement,codeRegion')).to eq(
        'codeDepartement' => '69', 'codeRegion' => '84'
      )
    end

    it 'returns nil on a not found response' do
      stub_request(:get, url).to_return(status: 404, body: '')

      expect(client.get('/communes/69123', fields: 'codeDepartement,codeRegion')).to be_nil
    end

    it 'returns nil on a server error' do
      stub_request(:get, url).to_return(status: 502, body: '')

      expect(client.get('/communes/69123', fields: 'codeDepartement,codeRegion')).to be_nil
    end

    it 'returns nil when the connection fails' do
      stub_request(:get, url).to_timeout

      expect(client.get('/communes/69123', fields: 'codeDepartement,codeRegion')).to be_nil
    end
  end
end
