RSpec.describe AuthorizationRequest::APIImpotParticulier, type: :model do
  subject(:authorization_request) do
    build(
      :authorization_request,
      :api_impot_particulier_production_avec_editeur,
      fill_all_attributes: true,
      skip_scopes_build: true,
      modalities:,
      france_connect_authorization_id:,
      scopes:,
      specific_requirements:,
      volumetrie_appels_par_minute:,
      volumetrie_justification:,
      safety_certification_begin_date:,
      safety_certification_end_date:,
      organization:
    )
  end

  let(:modalities) { ['with_spi'] }
  let(:france_connect_authorization_id) { nil }
  let(:scopes) { [] }
  let(:specific_requirements) { nil }
  let(:volumetrie_appels_par_minute) { nil }
  let(:volumetrie_justification) { nil }
  let(:safety_certification_begin_date) { nil }
  let(:safety_certification_end_date) { nil }
  let(:organization) { nil }

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

  describe 'modalities validation' do
    before { authorization_request.current_build_step = 'modalities' }

    context 'with a non array value' do
      it 'raises a type error' do
        expect { authorization_request.modalities = 'non array value' }.to raise_error(TypeError)
      end
    end

    context 'with no value' do
      before { authorization_request.modalities = nil }

      it { is_expected.not_to be_valid }
    end

    context 'with empty value' do
      before { authorization_request.modalities = [] }

      it { is_expected.not_to be_valid }
    end

    context 'with bad value' do
      let(:modalities) { ['bad_value'] }

      it { is_expected.not_to be_valid }
    end

    context 'with good value' do
      let(:modalities) { ['with_spi'] }

      it { is_expected.to be_valid }
    end

    context 'with france connect' do
      let(:modalities) { ['with_france_connect'] }

      context 'without any france connect authorization id' do
        let(:france_connect_authorization_id) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'with an invalid france connect authorization id' do
        let(:france_connect_authorization_id) { 0 }

        it { is_expected.not_to be_valid }
      end

      context 'with a france connect authorization id from another organization' do
        let(:validated_france_connect_authorization_request) { create(:authorization_request, :france_connect, :validated) }
        let(:france_connect_authorization_id) { validated_france_connect_authorization_request.authorizations.first.id.to_s }

        it { is_expected.not_to be_valid }
      end

      context 'with a revoked france connect authorization id from the same organization' do
        let(:validated_france_connect_authorization_request) { create(:authorization_request, :france_connect, :revoked) }
        let(:organization) { validated_france_connect_authorization_request.organization }
        let(:france_connect_authorization_id) { validated_france_connect_authorization_request.authorizations.first.id.to_s }

        it { is_expected.not_to be_valid }
      end

      context 'with a validated france connect authorization id from the same organization' do
        let(:validated_france_connect_authorization_request) { create(:authorization_request, :france_connect, :validated) }
        let(:organization) { validated_france_connect_authorization_request.organization }
        let(:france_connect_authorization_id) { validated_france_connect_authorization_request.authorizations.first.id.to_s }

        it { is_expected.to be_valid }

        describe 'when switched to spi and saved' do
          before do
            authorization_request.modalities = ['with_spi']
            authorization_request.save
          end

          it 'removes the france_connect_authorization_id' do
            expect(authorization_request.france_connect_authorization_id).to be_nil
          end
        end
      end
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
          expect(authorization_request.errors[:specific_requirements_document]).to include('est manquant : vous devez ajoutez un fichier avant de passer à l’étape suivante')
        end
      end

      context 'with specific requirements is selected with a document attached and no scope selected' do
        let(:specific_requirements) { '1' }
        let(:scopes) { [] }

        before do
          authorization_request.specific_requirements_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))
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

    context 'when specific requirement is not selected' do
      let(:specific_requirements) { '0' }
      let(:scopes) { %w[dgfip_annee_n_moins_2] }

      it { is_expected.to be_valid }
    end

    context 'when specific requirement is selected and one document is attached' do
      let(:specific_requirements) { '1' }
      let(:scopes) { %w[dgfip_annee_n_moins_2] }

      before do
        authorization_request.specific_requirements_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))
      end

      it { is_expected.to be_valid }
    end

    context 'when specific requirement is selected but no document is attached' do
      let(:specific_requirements) { '1' }
      let(:scopes) { %w[dgfip_annee_n_moins_2] }

      it { is_expected.not_to be_valid }

      it 'does render an error message for specific requirements' do
        authorization_request.valid?
        expect(authorization_request.errors[:specific_requirements_document]).to include('est manquant : vous devez ajoutez un fichier avant de passer à l’étape suivante')
      end
    end
  end
end
