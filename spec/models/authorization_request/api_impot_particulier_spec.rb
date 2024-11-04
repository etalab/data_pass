RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  subject(:authorization_request) do
    build(
      :authorization_request,
      :api_impot_particulier_editeur,
      fill_all_attributes: true,
      skip_scopes_build: true,
      scopes:,
      specific_requirements:,
      volumetrie_appels_par_minute:,
      volumetrie_justification:,
      safety_certification_begin_date:,
      safety_certification_end_date:
    )
  end

  let(:scopes) { [] }
  let(:specific_requirements) { nil }
  let(:volumetrie_appels_par_minute) { nil }
  let(:volumetrie_justification) { nil }
  let(:safety_certification_begin_date) { nil }
  let(:safety_certification_end_date) { nil }

  describe 'volumetrie validation' do
    before { authorization_request.current_build_step = 'volumetrie' }

    context 'with minimum volumetrie and no justification' do
      let(:scopes) { %w[dgfip_annee_n_moins_2] }
      let(:volumetrie_appels_par_minute) { 50 }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and a justification' do
      let(:scopes) { %w[dgfip_annee_n_moins_2] }
      let(:volumetrie_appels_par_minute) { 200 }
      let(:volumetrie_justification) { 'A good justification' }

      it { is_expected.to be_valid }
    end

    context 'with high volumetrie and no justification' do
      let(:scopes) { %w[dgfip_annee_n_moins_2] }
      let(:volumetrie_appels_par_minute) { 200 }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'safety certification valitation' do
    before { authorization_request.current_build_step = 'safety_certification' }

    context 'with coherent dates' do
      let(:scopes) { %w[dgfip_annee_n_moins_2] }
      let(:safety_certification_begin_date) { Date.yesterday }
      let(:safety_certification_end_date) { Date.tomorrow }

      it { is_expected.to be_valid }
    end

    context 'with incoherent dates' do
      let(:scopes) { %w[dgfip_annee_n_moins_2] }
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

        it 'does render en error message' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes]).to include('sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer')
        end
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

        it 'does render an error message for invalid exclusive years scope combination' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes]).to include("sont invalides : Vous ne pouvez pas sélectionner la donnée 'avant dernière année de revenu, si la dernière année de revenu est indisponible' avec d'autres années de revenus")
        end
      end
    end

    describe 'validation with incompatible scopes' do
      context 'with an incompatible scopes combination' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_indiIFI] }

        it { is_expected.not_to be_valid }

        it 'does render an error message' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes].first).to match(/Des données incompatibles entre elles ont été cochées/)
        end
      end

      context 'with valid scopes combination from specials scopes' do
        let(:scopes) { %w[dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_annee_n_moins_2_si_indispo_n_moins_1] }

        it { is_expected.to be_valid }
      end

      context 'with invalid complex scopes combination from special scopes and incompatible scopes' do
        let(:scopes) { %w[dgfip_annee_n_moins_2_si_indispo_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_indiIFI dgfip_RevDecl_Cat1_Tspr] }

        it { is_expected.not_to be_valid }

        it 'does render an error message for invalid scope combination' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes].first).to match(/Des données incompatibles entre elles ont été cochées./)
        end
      end

      context 'with valid incompatible scopes combination with at least one simple revenue years scope' do
        let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_indiIFI] }

        it { is_expected.to be_valid }
      end
    end

    describe 'specific requirements with no scopes' do
      context 'when specific requirements is selected and no document attached' do
        let(:specific_requirements) { '1' }
        let(:scopes) { [] }

        it { is_expected.not_to be_valid }

        it 'does render an error message for specific requirements' do
          authorization_request.valid?
          expect(authorization_request.errors[:specific_requirements_document]).to include('est manquant : vous devez joindre votre document')
        end

        it 'does render errors message for data not selected' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes]).to include("ne sont pas cochées : il faut au moins qu'une des données soit sélectionnée.")
        end

        it 'does render en error message for invalid data' do
          authorization_request.valid?
          expect(authorization_request.errors[:scopes]).to include('sont invalides : Vous devez cocher au moins une année de revenus souhaitée avant de continuer')
        end
      end

      context 'with specific requirements is selected with a document attached and no scope selected' do
        let(:specific_requirements) { '1' }
        let(:scopes) { [] }

        before do
          authorization_request.specific_requirements_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.ms-excel'))
        end

        it 'attaches the specific requirements document' do
          expect(authorization_request.specific_requirements_document).to be_attached
          expect(authorization_request.specific_requirements_document.filename).to eq('dummy.xlsx')
        end

        it { is_expected.to be_valid }

        it 'does not render an error' do
          authorization_request.valid?
          expect(authorization_request.errors[:specific_requirements_document]).to be_empty
        end
      end
    end
  end

  describe 'specific requirements with scopes' do
    before { authorization_request.current_build_step = 'scopes' }

    describe 'Valid case' do
      context 'when specific requirement is not selected' do
        let(:specific_requirements) { '0' }
        let(:scopes) { %w[dgfip_annee_n_moins_2] }

        it { is_expected.to be_valid }
      end

      context 'when specific requirement is selected and one document is attached' do
        let(:specific_requirements) { '1' }
        let(:scopes) { %w[dgfip_annee_n_moins_2] }

        before do
          authorization_request.specific_requirements_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.ms-excel'))
        end

        it 'attaches the specific requirements document' do
          expect(authorization_request.specific_requirements_document).to be_attached
          expect(authorization_request.specific_requirements_document.filename).to eq('dummy.xlsx')
        end

        it { is_expected.to be_valid }
      end
    end

    describe 'Invalid case' do
      context 'when specific requirement is selected but no document is attached' do
        let(:specific_requirements) { '1' }
        let(:scopes) { %w[dgfip_annee_n_moins_2] }

        it 'has no document attached' do
          expect(authorization_request.specific_requirements_document).not_to be_attached
        end

        it { is_expected.not_to be_valid }

        it 'does render an error message for specific requirements' do
          authorization_request.valid?
          expect(authorization_request.errors[:specific_requirements_document]).to include('est manquant : vous devez joindre votre document')
        end
      end
    end
  end
end
