require 'rails_helper'

RSpec.describe HeaderHelper do
  let(:subdomain) { nil }

  before do
    allow(helper).to receive_messages(registered_subdomain: subdomain)
  end

  describe '#header_title' do
    it 'returns DataPass by default' do
      expect(helper.header_title).to eq('DataPass')
    end

    context 'with a subdomain that has its own title' do
      let(:subdomain) { instance_double(Subdomain, title: 'API Particulier', tagline: nil) }

      it 'returns the subdomain title' do
        expect(helper.header_title).to eq('API Particulier')
      end
    end
  end

  describe '#header_tagline' do
    it 'returns the default tagline' do
      expect(helper.header_tagline).to eq('Habilitations juridiques')
    end

    context 'with a subdomain that has its own tagline' do
      let(:subdomain) { instance_double(Subdomain, title: nil, tagline: 'Accès aux données fiscales') }

      it 'returns the subdomain tagline' do
        expect(helper.header_tagline).to eq('Accès aux données fiscales')
      end
    end
  end
end
