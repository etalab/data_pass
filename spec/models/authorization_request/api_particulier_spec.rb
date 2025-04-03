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
end
