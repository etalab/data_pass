require 'rails_helper'

RSpec.describe AuthorizationRequestFormBuilder, type: :helper do
  subject(:builder) { described_class.new(:authorization_request, authorization_request, helper, {}) }

  let(:authorization_request) { build(:authorization_request, :api_particulier) }

  describe '#france_connect_cgu_required?' do
    context 'when authorization request has france_connect modality and fc_certified form' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      it 'returns true' do
        expect(builder.send(:france_connect_cgu_required?)).to be true
      end
    end

    context 'when authorization request has france_connect modality but form is not fc_certified' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier, :with_france_connect_embedded_fields)
      end

      it 'returns false' do
        expect(builder.send(:france_connect_cgu_required?)).to be false
      end
    end

    context 'when authorization request does not have france_connect modality' do
      let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik) }

      it 'returns false' do
        expect(builder.send(:france_connect_cgu_required?)).to be false
      end
    end

    context 'when authorization request does not respond to france_connect_modality?' do
      let(:authorization_request) { build(:authorization_request, :api_entreprise) }

      it 'returns false' do
        expect(builder.send(:france_connect_cgu_required?)).to be false
      end
    end
  end

  describe '#cgu_label_text' do
    context 'when france_connect cgu is required' do
      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields)
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      it 'includes the API Particulier CGU link' do
        expect(builder.send(:cgu_label_text)).to include('https://particulier.api.gouv.fr/cgu')
      end

      it 'includes the FranceConnect CGU link' do
        expect(builder.send(:cgu_label_text)).to include('https://partenaires.franceconnect.gouv.fr/cgu')
      end

      it 'includes explicit link text for API Particulier' do
        expect(builder.send(:cgu_label_text)).to include("conditions générales d\u2019utilisation de l\u2019API Particulier")
      end

      it 'includes explicit link text for FranceConnect' do
        expect(builder.send(:cgu_label_text)).to include("conditions générales d\u2019utilisation de FranceConnect")
      end
    end

    context 'when france_connect cgu is not required' do
      let(:authorization_request) { build(:authorization_request, :api_particulier) }

      it 'includes only the API Particulier CGU link' do
        expect(builder.send(:cgu_label_text)).to include('https://particulier.api.gouv.fr/cgu')
      end

      it 'does not include the FranceConnect CGU link' do
        expect(builder.send(:cgu_label_text)).not_to include('https://partenaires.franceconnect.gouv.fr/cgu')
      end
    end
  end
end
