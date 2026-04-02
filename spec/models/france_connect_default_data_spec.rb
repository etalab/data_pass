require 'rails_helper'

RSpec.describe FranceConnectDefaultData do
  let(:authorization_request) { create(:authorization_request, :api_particulier_entrouvert_publik, fill_all_attributes: true) }

  describe '.attributes' do
    it 'returns FC default attributes' do
      expect(described_class.attributes).to eq(
        fc_eidas: 'eidas_1',
        fc_cadre_juridique_nature: 'Arrêté du 8 novembre 2018',
        fc_cadre_juridique_url: 'https://www.legifrance.gouv.fr/loda/id/JORFTEXT000037611479'
      )
    end
  end

  describe '.scope_values' do
    it 'returns FranceConnect scopes from API Particulier definition' do
      expect(described_class.scope_values).to contain_exactly(
        'family_name', 'given_name', 'birthdate', 'birthplace', 'birthcountry', 'gender', 'openid'
      )
    end
  end

  describe '.assign_to' do
    context 'when FC attributes are blank' do
      before do
        authorization_request.fc_eidas = nil
        authorization_request.fc_cadre_juridique_nature = nil
        authorization_request.fc_cadre_juridique_url = nil
        authorization_request.scopes = %w[cnaf_quotient_familial]
      end

      it 'assigns FC attributes' do
        described_class.assign_to(authorization_request)

        expect(authorization_request.fc_eidas).to eq('eidas_1')
        expect(authorization_request.fc_cadre_juridique_nature).to eq('Arrêté du 8 novembre 2018')
        expect(authorization_request.fc_cadre_juridique_url).to eq('https://www.legifrance.gouv.fr/loda/id/JORFTEXT000037611479')
      end

      it 'adds missing FC scopes without removing existing ones' do
        described_class.assign_to(authorization_request)

        expect(authorization_request.scopes).to include('cnaf_quotient_familial')
        expect(authorization_request.scopes).to include('family_name', 'given_name', 'birthdate', 'birthplace', 'birthcountry', 'gender', 'openid')
      end
    end

    context 'when FC attributes are already filled by the user' do
      before do
        authorization_request.fc_eidas = 'eidas_2'
        authorization_request.fc_cadre_juridique_nature = 'Custom nature'
        authorization_request.fc_cadre_juridique_url = 'https://example.com/custom'
        authorization_request.scopes = %w[cnaf_quotient_familial family_name given_name birthdate birthplace birthcountry gender openid]
      end

      it 'does not overwrite existing FC attributes' do
        described_class.assign_to(authorization_request)

        expect(authorization_request.fc_eidas).to eq('eidas_2')
        expect(authorization_request.fc_cadre_juridique_nature).to eq('Custom nature')
        expect(authorization_request.fc_cadre_juridique_url).to eq('https://example.com/custom')
      end

      it 'does not modify scopes when all FC scopes are present' do
        scopes_before = authorization_request.scopes.dup

        described_class.assign_to(authorization_request)

        expect(authorization_request.scopes).to eq(scopes_before)
      end
    end
  end
end
