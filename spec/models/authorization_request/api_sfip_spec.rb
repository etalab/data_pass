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
  end
end
