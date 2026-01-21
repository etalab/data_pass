# rubocop:disable Style/FormatStringToken
RSpec.describe MessageTemplateInterpolator do
  subject(:interpolator) { described_class.new(content) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, intitule: 'intitule') }

  describe '#interpolate' do
    subject(:interpolate) { interpolator.interpolate(authorization_request) }

    context 'with valid content' do
      let(:content) { 'test1 %{demande_url} test2 %{demande_intitule} test3 %{demande_id}' }

      it 'works' do
        expect(interpolate).to eq("test1 http://localhost:3000/demandes/#{authorization_request.id} test2 intitule test3 #{authorization_request.id}")
      end
    end

    context 'with invalid content' do
      let(:content) { '%{invalid}' }

      it 'raises an error' do
        expect { interpolate }.to raise_error(ArgumentError)
      end
    end

    context 'with URL containing percent signs' do
      let(:content) { 'Visit https://example.com/path%20with%20spaces and %{demande_url}' }

      it 'interpolates correctly' do
        result = interpolate
        expect(result).to include('https://example.com/path%20with%20spaces')
        expect(result).to include("http://localhost:3000/demandes/#{authorization_request.id}")
      end
    end

    context 'with percent signs in content' do
      let(:content) { 'This is 50% complete. URL: https://staging.datapass.api.gouv.fr/instruction/modeles-messages%20/new' }

      it 'interpolates correctly without errors' do
        expect { interpolate }.not_to raise_error
        result = interpolate
        expect(result).to include('50%')
        expect(result).to include('https://staging.datapass.api.gouv.fr/instruction/modeles-messages%20/new')
      end
    end
  end

  describe '#valid?' do
    subject(:valid?) { interpolator.valid?(authorization_request) }

    context 'with allowed variables' do
      let(:content) { 'test1 %{demande_url} test2 %{demande_intitule} test3 %{demande_id}' }

      it { is_expected.to be true }
    end

    context 'with some invalid variables' do
      let(:content) { 'test1 %{demande_url} test2 %{invalid}' }

      it { is_expected.not_to be true }
    end

    context 'with URL containing percent signs' do
      let(:content) { 'Visit https://example.com/path%20with%20spaces and %{demande_url}' }

      it { is_expected.to be true }
    end

    context 'with percent signs in content' do
      let(:content) { 'This is 50% complete. URL: https://staging.datapass.api.gouv.fr/instruction/modeles-messages%20/new' }

      it { is_expected.to be true }
    end
  end
end
# rubocop:enable Style/FormatStringToken
