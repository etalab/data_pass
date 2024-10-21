RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  describe 'volumetrie validation' do
    subject(:authorization_request) { build(:authorization_request, :api_impot_particulier_editeur, fill_all_attributes: true, volumetrie_appels_par_minute:, volumetrie_justification:) }

    before { authorization_request.current_build_step = 'volumetrie' }

    context 'with minimum volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 50 }
      let(:volumetrie_justification) { nil }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and a justification' do
      let(:volumetrie_appels_par_minute) { 200 }
      let(:volumetrie_justification) { 'A good justification' }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 200 }
      let(:volumetrie_justification) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'safety certification valitation' do
    subject(:authorization_request) { build(:authorization_request, :api_impot_particulier_editeur, fill_all_attributes: true, safety_certification_begin_date:, safety_certification_end_date:) }

    before { authorization_request.current_build_step = 'safety_certification' }

    context 'with coherent dates' do
      let(:safety_certification_begin_date) { Date.yesterday }
      let(:safety_certification_end_date) { Date.tomorrow }

      it { is_expected.to be_valid }
    end

    context 'with incoherent dates' do
      let(:safety_certification_begin_date) { Date.tomorrow }
      let(:safety_certification_end_date) { Date.yesterday }

      it { is_expected.not_to be_valid }
    end
  end
end
