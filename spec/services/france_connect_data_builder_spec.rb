require 'rails_helper'

RSpec.describe FranceConnectDataBuilder do
  describe '#data' do
    subject(:data) { described_class.new(authorization_request).data }

    let(:authorization_request) do
      create(:authorization_request, :api_particulier, :with_france_connect_embedded_fields, fill_all_attributes: true)
    end

    it 'returns a hash with string keys' do
      expect(data.keys).to all(be_a(String))
    end

    it 'includes scopes' do
      expect(data['scopes']).to be_present
    end

    it 'includes cadre_juridique_nature' do
      expect(data['cadre_juridique_nature']).to be_present
    end

    it 'normalizes alternative_connexion checkbox value to "1" not "true"' do
      authorization_request.fc_alternative_connexion = '1'

      expect(data['alternative_connexion']).to eq('1')
    end

    it 'normalizes alternative_connexion checkbox value to "0" when unchecked' do
      authorization_request.fc_alternative_connexion = '0'

      expect(data['alternative_connexion']).to eq('0')
    end

    context 'when the request does not have france_connect modality' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier, fill_all_attributes: true)
      end

      it 'returns an empty hash' do
        expect(data).to eq({})
      end
    end
  end

  describe '#attach_documents_to' do
    subject(:attach_documents) { described_class.new(authorization_request).attach_documents_to(authorization) }

    let(:authorization_request) do
      create(:authorization_request, :api_particulier, :with_france_connect_embedded_fields, fill_all_attributes: true)
    end
    let(:authorization) { create(:authorization, authorization_request_trait: :france_connect) }

    it 'delegates to authorization_request' do
      allow(authorization_request).to receive(:attach_documents_to_france_connect_authorization)

      attach_documents

      expect(authorization_request).to have_received(:attach_documents_to_france_connect_authorization).with(authorization)
    end
  end
end
