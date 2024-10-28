RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  subject(:authorization_request) { build(:authorization_request, :api_impot_particulier_editeur, fill_all_attributes: true, scopes:, volumetrie_appels_par_minute:, volumetrie_justification:, safety_certification_begin_date:, safety_certification_end_date:) }

  let(:scopes) { [] }
  let(:volumetrie_appels_par_minute) { nil }
  let(:volumetrie_justification) { nil }
  let(:safety_certification_begin_date) { nil }
  let(:safety_certification_end_date) { nil }

  describe 'volumetrie validation' do
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

  describe 'scopes validation of revenue years' do
    before { authorization_request.current_build_step = 'scopes' }

    AuthorizationRequest::APIImpotParticulier::MANDATORY_REVENUE_YEARS.each do |year|
      context "with mandatory revenue year scope #{year}" do
        let(:scopes) { [year] }

        it { is_expected.to be_valid }
      end
    end

    context 'without any revenue years scope selected' do
      let(:scopes) { %w[dgfip_indiIFI] }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'validation of exclusive revenue years scope combination' do
    before { authorization_request.current_build_step = 'scopes' }

    AuthorizationRequest::APIImpotParticulier::EXCLUSIVE_REVENUE_YEARS.each do |exclusive_group|
      context "with valid exclusive years scope combination: #{exclusive_group.join(', ')}" do
        let(:scopes) { exclusive_group }

        it { is_expected.to be_valid }
      end
    end

    context 'with invalid exclusive revenue years scope combination' do
      let(:scopes) { %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_n_moins_1] }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'validation with incompatible scopes' do
    before { authorization_request.current_build_step = 'scopes' }

    incompatible_combinations = AuthorizationRequest::APIImpotParticulier::INCOMPATIBLE_SCOPES.combination(2).map(&:flatten)

    incompatible_combinations.each do |incompatible_scopes|
      context "with incompatible scopes combination: #{incompatible_scopes.join(', ')}" do
        let(:scopes) { incompatible_scopes }

        it { is_expected.not_to be_valid }
      end
    end

    context 'with valid scopes combination from array_1' do
      let(:scopes) { %w[dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_annee_n_moins_2_si_indispo_n_moins_1] }

      it { is_expected.to be_valid }
    end

    context 'with invalid complex incompatible scopes combination from array_1 and array_2' do
      let(:scopes) { %w[dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_indiIFI dgfip_RevDecl_Cat1_Tspr] }

      it { is_expected.not_to be_valid }
    end

    context 'with valid incompatible scopes combination with revenue years scope' do
      let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_indiIFI] }

      it { is_expected.to be_valid }
    end
  end
end
