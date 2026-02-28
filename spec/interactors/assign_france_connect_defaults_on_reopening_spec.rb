require 'rails_helper'

RSpec.describe AssignFranceConnectDefaultsOnReopening do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:) }

    let(:fc_scope_values) { %w[family_name given_name birthdate birthplace birthcountry gender openid] }

    context 'when reopened APIPFC request adds FC modality with no existing FC authorization' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :reopened, fill_all_attributes: true)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params france_connect]
        authorization_request.fc_eidas = nil
        authorization_request.fc_cadre_juridique_nature = nil
        authorization_request.fc_cadre_juridique_url = nil
        authorization_request.scopes = %w[cnaf_quotient_familial]
      end

      it { is_expected.to be_success }

      it 'fills fc_eidas from form defaults' do
        interactor

        expect(authorization_request.fc_eidas).to eq('eidas_1')
      end

      it 'fills fc_cadre_juridique_nature from form defaults' do
        interactor

        expect(authorization_request.fc_cadre_juridique_nature).to be_present
      end

      it 'fills fc_cadre_juridique_url from form defaults' do
        interactor

        expect(authorization_request.fc_cadre_juridique_url).to be_present
      end

      it 'adds missing FC scopes to existing scopes' do
        interactor

        expect(authorization_request.scopes).to include(*fc_scope_values)
        expect(authorization_request.scopes).to include('cnaf_quotient_familial')
      end
    end

    context 'when FC fields are already filled by the user' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :reopened, fill_all_attributes: true)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params france_connect]
        authorization_request.fc_eidas = 'eidas_2'
        authorization_request.fc_cadre_juridique_nature = 'Custom nature'
        authorization_request.fc_cadre_juridique_url = 'https://example.com/custom'
        authorization_request.scopes = %w[cnaf_quotient_familial] + fc_scope_values
      end

      it 'does not overwrite fc_eidas' do
        interactor

        expect(authorization_request.fc_eidas).to eq('eidas_2')
      end

      it 'does not overwrite fc_cadre_juridique_nature' do
        interactor

        expect(authorization_request.fc_cadre_juridique_nature).to eq('Custom nature')
      end

      it 'does not overwrite fc_cadre_juridique_url' do
        interactor

        expect(authorization_request.fc_cadre_juridique_url).to eq('https://example.com/custom')
      end
    end

    context 'when an FC authorization already exists' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :reopened, fill_all_attributes: true)
      end
      let!(:existing_fc_authorization) do
        create(:authorization,
          request: authorization_request,
          authorization_request_class: 'AuthorizationRequest::FranceConnect')
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params france_connect]
        authorization_request.fc_eidas = nil
        authorization_request.scopes = %w[cnaf_quotient_familial]
      end

      it { is_expected.to be_success }

      it 'does not fill fc_eidas' do
        interactor

        expect(authorization_request.fc_eidas).to be_nil
      end

      it 'does not add FC scopes' do
        interactor

        expect(authorization_request.scopes).to eq(%w[cnaf_quotient_familial])
      end
    end

    context 'when france_connect_authorization_id is present (linked existing habilitation)' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :reopened, fill_all_attributes: true)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params france_connect]
        authorization_request.france_connect_authorization_id = '999'
        authorization_request.fc_eidas = nil
        authorization_request.scopes = %w[cnaf_quotient_familial]
      end

      it { is_expected.to be_success }

      it 'does not fill fc_eidas' do
        interactor

        expect(authorization_request.fc_eidas).to be_nil
      end

      it 'does not add FC scopes' do
        interactor

        expect(authorization_request.scopes).to eq(%w[cnaf_quotient_familial])
      end
    end

    context 'when FC modality is not selected' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, :reopened, fill_all_attributes: true)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params]
        authorization_request.fc_eidas = nil
      end

      it { is_expected.to be_success }

      it 'does not fill fc_eidas' do
        interactor

        expect(authorization_request.fc_eidas).to be_nil
      end
    end

    context 'when request is not reopened' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik, fill_all_attributes: true)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.modalities = %w[params france_connect]
        authorization_request.fc_eidas = nil
      end

      it { is_expected.to be_success }

      it 'does not fill fc_eidas' do
        interactor

        expect(authorization_request.fc_eidas).to be_nil
      end
    end

    context 'when request is not API Particulier' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, fill_all_attributes: true) }

      it { is_expected.to be_success }

      it 'does not modify the request' do
        scopes_before = authorization_request.scopes.dup
        interactor

        expect(authorization_request.scopes).to eq(scopes_before)
      end
    end
  end
end
