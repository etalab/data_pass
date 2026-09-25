RSpec.describe AuthorizationRequest::APIFicoba do
  subject(:authorization_request) do
    build(
      :authorization_request,
      :api_ficoba_production,
      fill_all_attributes: true,
      volumetrie_appels_par_minute:,
      volumetrie_justification:
    )
  end

  let(:volumetrie_appels_par_minute) { nil }
  let(:volumetrie_justification) { nil }

  describe 'available volumetries' do
    it 'offers the rate limits agreed with the DGFiP' do
      expect(described_class::VOLUMETRIES.values).to eq([200, 500, 750])
    end
  end

  describe 'volumetrie validation' do
    before { authorization_request.current_build_step = 'volumetrie' }

    context 'with the smallest volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 200 }

      it { is_expected.to be_valid }
    end

    context 'with the highest volumetrie and a justification' do
      let(:volumetrie_appels_par_minute) { 750 }
      let(:volumetrie_justification) { 'Une bonne justification' }

      it { is_expected.to be_valid }
    end

    context 'with the highest volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 750 }

      it { is_expected.not_to be_valid }
    end

    context 'with a volumetrie no longer offered, coming from an existing record' do
      let(:volumetrie_appels_par_minute) { 700 }
      let(:volumetrie_justification) { 'Une bonne justification' }

      it { is_expected.to be_valid }
    end
  end
end
