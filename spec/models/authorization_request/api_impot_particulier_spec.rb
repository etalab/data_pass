RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  subject(:authorization_request) { build(:authorization_request, :api_impot_particulier_editeur, fill_all_attributes: true, scopes:, specific_requirements:, volumetrie_appels_par_minute:, volumetrie_justification:, safety_certification_begin_date:, safety_certification_end_date:) }

  let(:scopes) { [] }
  let(:specific_requirements) { nil }
  let(:volumetrie_appels_par_minute) { nil }
  let(:volumetrie_justification) { nil }
  let(:safety_certification_begin_date) { nil }
  let(:safety_certification_end_date) { nil }

  describe 'volumetrie validation' do
    before { authorization_request.current_build_step = 'volumetrie' }

    context 'with minimum volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 50 }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and a justification' do
      let(:volumetrie_appels_par_minute) { 200 }
      let(:volumetrie_justification) { 'A good justification' }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and no justification' do
      let(:volumetrie_appels_par_minute) { 200 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'safety certification valitation' do
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

  describe 'scopes validation' do
    before { authorization_request.current_build_step = 'scopes' }

    describe 'at least one mandatory year is selected' do
      context 'with revenue year scope selected' do
        let(:scopes) { %w[dgfip_annee_n_moins_1] }

        it { is_expected.to be_valid }
      end

      context 'without any revenue years scope selected' do
        let(:scopes) { %w[dgfip_rfr] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'validation of exclusive revenue years scope combination' do
      context 'with valid exclusive years scope combination' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_3] }

        it { is_expected.to be_valid }
      end

      context 'with invalid exclusive revenue years scope combination' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2_si_indispo_n_moins_1] }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'validation with incompatible scopes' do
      context 'with an incompatible scopes combination' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_indiIFI] }

        it { is_expected.not_to be_valid }
      end

      context 'with valid scopes combination from specials scopes' do
        let(:scopes) { %w[dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_annee_n_moins_2_si_indispo_n_moins_1] }

        it { is_expected.to be_valid }
      end

      context 'with invalid complex scopes combination from special scopes and incompatible scopes' do
        let(:scopes) { %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_indiIFI dgfip_RevDecl_Cat1_Tspr] }

        it { is_expected.not_to be_valid }
      end

      context 'with valid incompatible scopes combination with at least one simple revenue years scope' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_indiIFI] }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'specific requirements' do
    before { authorization_request.current_build_step = 'scopes' }

    describe 'Valid case' do
      context 'when specific requirement is not selected' do
        let(:specific_requirements) { false }

        it { is_expected.to be_valid }
      end

      context 'when specific requirement is selected and one document is attached' do
        let(:specific_requirements) { true }

        it 'attaches the specific requirements document' do
          authorization_request.specific_requirements_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.ms-excel'))

          expect(authorization_request.specific_requirements_document).to be_attached
          expect(authorization_request.specific_requirements_document.filename).to eq('dummy.xlsx')
        end

        it { is_expected.to be_valid }
      end
    end

    describe 'Invalid case' do
      context 'when specific requirement is selected but no document is attached' do
        let(:specific_requirements) { true }

        it 'has no document attached' do
          expect(authorization_request.specific_requirements_document).not_to be_attached
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
