RSpec.describe 'Instruction::Formulaires' do
  let(:data_provider) { create(:data_provider, :dgfip) }
  let(:formulaire_id) { 'api_impot_particulier' }

  describe 'GET /instruction/fournisseurs-donnees/:slug/formulaires' do
    subject(:get_index) do
      get instruction_formulaires_path(provider_slug: data_provider.slug)
      response
    end

    context 'when user is admin' do
      before { sign_in(create(:user, :admin)) }

      it { is_expected.to have_http_status(:ok) }

      it 'renders the data provider name' do
        get_index
        expect(response.body).to include(data_provider.name)
      end

      context 'when the provider slug does not exist' do
        it 'returns 404' do
          get instruction_formulaires_path(provider_slug: 'unknown')
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is FD reporter scoped to the provider' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dgfip])) }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when user is reporter scoped to another FD' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dinum])) }

      it 'redirects (unauthorized)' do
        get_index
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user has no reporter coverage' do
      before { sign_in(create(:user)) }

      it 'redirects to dashboard (InstructionController gate)' do
        get_index
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context 'when unauthenticated' do
      it 'redirects' do
        get_index
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET /instruction/fournisseurs-donnees/:slug/formulaires/:id' do
    context 'when user is admin' do
      before { sign_in(create(:user, :admin)) }

      it 'returns 200 on happy path' do
        get instruction_formulaire_path(provider_slug: data_provider.slug, id: formulaire_id)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('API Impôt Particulier')
      end

      it 'returns 404 when the formulaire belongs to another provider' do
        other_provider = create(:data_provider, :dinum)
        get instruction_formulaire_path(provider_slug: other_provider.slug, id: formulaire_id)
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 when the formulaire id is unknown' do
        get instruction_formulaire_path(provider_slug: data_provider.slug, id: 'does_not_exist')
        expect(response).to have_http_status(:not_found)
      end

      it 'renders demandes + habilitations stats on cas d’usage cards' do
        get instruction_formulaire_path(provider_slug: data_provider.slug, id: formulaire_id)
        expect(response.body).to match(/demande/i)
        expect(response.body).to match(/habilitation/i)
      end
    end

    context 'when user is FD reporter scoped to the provider' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dgfip])) }

      it 'returns 200' do
        get instruction_formulaire_path(provider_slug: data_provider.slug, id: formulaire_id)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is reporter scoped to another FD' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dinum])) }

      it 'redirects (unauthorized)' do
        get instruction_formulaire_path(provider_slug: data_provider.slug, id: formulaire_id)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
