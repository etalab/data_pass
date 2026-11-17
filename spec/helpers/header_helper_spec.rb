require 'rails_helper'

RSpec.describe HeaderHelper do
  let(:subdomain) { nil }
  let(:public_header) { true }

  before do
    allow(helper).to receive_messages(registered_subdomain: subdomain, public_header?: public_header)
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
    it 'returns the public tagline for a signed out visitor' do
      expect(helper.header_tagline).to eq('Habilitations et registre du portefeuille européen')
    end

    context 'when the header is not public' do
      let(:public_header) { false }

      it 'returns the default tagline' do
        expect(helper.header_tagline).to eq('Habilitations juridiques')
      end
    end

    context 'with a subdomain that has its own tagline' do
      let(:subdomain) { instance_double(Subdomain, title: nil, tagline: 'Accès aux données fiscales') }

      it 'returns the subdomain tagline' do
        expect(helper.header_tagline).to eq('Accès aux données fiscales')
      end
    end
  end

  describe '#public_menu_links' do
    it 'lists the home page and the European wallet page' do
      expect(helper.public_menu_links).to eq([
        { label: 'Accueil', path: '/' },
        { label: 'Portefeuille européen', path: '/#portefeuille-europeen' }
      ])
    end
  end
end
