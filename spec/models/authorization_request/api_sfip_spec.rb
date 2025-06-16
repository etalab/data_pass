RSpec.describe AuthorizationRequest::APISFiP do
  subject(:authorization_request) do
    build(
      :authorization_request,
      :api_sfip_sandbox,
      fill_all_attributes: true,
      skip_scopes_build: true,
      scopes: scopes
    )
  end

  let(:scopes) { [] }

  describe 'regression test for translation keys of validation errors' do
    before { authorization_request.current_build_step = 'scopes' }

    context 'without any revenue years scope selected' do
      it 'fails validation' do
        expect(authorization_request).not_to be_valid
      end

      it 'has a correct error message' do
        authorization_request.valid?
        expect(authorization_request.errors.full_messages.join("\n")).to include('Vous devez cocher au moins une année de revenus')
      end
    end

    context 'with incompatible scopes combination' do
      let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_df_au_3112_si_deces_ctb_mp dgfip_indiIFI] }

      it 'fails validation' do
        expect(authorization_request).not_to be_valid
      end

      it 'has a correct error message' do
        authorization_request.valid?
        expect(authorization_request.errors.full_messages.join("\n")).to include('Des données incompatibles entre elles ont été cochées')
      end
    end

    context 'with revenue years scopes' do
      let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_annee_n_moins_2_si_indispo_n_moins_1] }

      it 'fails validation' do
        expect(authorization_request).not_to be_valid
      end

      it 'has a correct error message' do
        authorization_request.valid?
        expect(authorization_request.errors.full_messages.join("\n")).to include("Vous ne pouvez pas sélectionner la donnée 'Avant-dernière année de revenu, si la dernière année de revenu est indisponible'")
      end
    end

    context 'with LEP scope and other scopes' do
      let(:scopes) { %w[dgfip_annee_n_moins_1 dgfip_IndLep] }

      it 'fails validation' do
        expect(authorization_request).not_to be_valid
      end

      it 'has a correct error message' do
        authorization_request.valid?
        expect(authorization_request.errors.full_messages.join("\n")).to include('La donnée d’indicateur d’éligibilité au LEP ne peut être demandée que seule')
      end
    end

    context 'with only LEP scope' do
      let(:scopes) { %w[dgfip_IndLep] }

      it 'passes validation completely' do
        expect(authorization_request).to be_valid
      end
    end
  end
end
