RSpec.describe AuthorizationRequest::APIParticulier do
  describe 'modalities attribute' do
    subject { authorization_request.modalities }

    let(:authorization_request) { build(:authorization_request, :api_particulier) }

    it { is_expected.to be_a(Array) }

    it 'has a default value' do
      expect(subject).to eq(%w[params])
    end

    context 'with values' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, modalities: %w[params formulaire_qf]) }

      it { is_expected.to eq(%w[formulaire_qf params]) }
    end
  end

  describe 'modalities validation' do
    subject { build(:authorization_request, :api_particulier, modalities:) }

    context 'with valid values' do
      let(:modalities) { %w[formulaire_qf params] }

      it { is_expected.to be_valid }
    end

    context 'with invalid values' do
      let(:modalities) { %w[invalid] }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#skip_france_connect_authorization?' do
    subject { authorization_request.skip_france_connect_authorization? }

    context 'when service provider is fc_certified and feature flag is enabled' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(true)
      end

      let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik) }

      it { is_expected.to be true }
    end

    context 'when service provider is fc_certified but feature flag is disabled' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(false)
      end

      let(:authorization_request) { build(:authorization_request, :api_particulier_entrouvert_publik) }

      it { is_expected.to be false }
    end

    context 'when service provider is not fc_certified' do
      let(:authorization_request) { build(:authorization_request, :api_particulier_arpege_concerto) }

      it { is_expected.to be false }
    end
  end

  describe '#requires_france_connect_authorization?' do
    subject { authorization_request.requires_france_connect_authorization? }

    context 'when skip_france_connect_authorization? is true' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(true)
      end

      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, modalities: ['france_connect'])
      end

      it { is_expected.to be false }
    end

    context 'when skip_france_connect_authorization? is false and france_connect modality selected' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:feature_flags, :apipfc).and_return(false)
        allow(authorization_request).to receive(:need_complete_validation?).with(:modalities).and_return(true)
      end

      let(:authorization_request) do
        build(:authorization_request, :api_particulier_entrouvert_publik, modalities: ['france_connect'])
      end

      it { is_expected.to be true }
    end
  end
end
