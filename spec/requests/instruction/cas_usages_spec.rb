RSpec.describe 'Instruction::CasUsages' do
  let(:data_provider) { create(:data_provider, :dgfip) }
  let(:formulaire_id) { 'api_impot_particulier' }
  let(:cas_usage_uid) { AuthorizationDefinition.find(formulaire_id).available_forms.first.uid }

  describe 'GET /instruction/fournisseurs-donnees/:slug/formulaires/:formulaire_id/cas-usage/:uid' do
    subject(:get_show) do
      get instruction_formulaire_cas_usage_path(
        provider_slug: data_provider.slug,
        formulaire_id: formulaire_id,
        uid: cas_usage_uid
      )
      response
    end

    context 'when user is admin' do
      before { sign_in(create(:user, :admin)) }

      it { is_expected.to have_http_status(:ok) }

      it 'returns 404 when the formulaire belongs to another provider' do
        other_provider = create(:data_provider, :dinum)
        get instruction_formulaire_cas_usage_path(
          provider_slug: other_provider.slug,
          formulaire_id: formulaire_id,
          uid: cas_usage_uid
        )
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 when the cas d’usage uid is unknown' do
        get instruction_formulaire_cas_usage_path(
          provider_slug: data_provider.slug,
          formulaire_id: formulaire_id,
          uid: 'does_not_exist'
        )
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 when the data provider slug is unknown' do
        get instruction_formulaire_cas_usage_path(
          provider_slug: 'unknown',
          formulaire_id: formulaire_id,
          uid: cas_usage_uid
        )
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is FD reporter scoped to the provider' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dgfip])) }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when user is reporter scoped to another FD' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dinum])) }

      it 'redirects (unauthorized)' do
        get_show
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user has no reporter coverage' do
      before { sign_in(create(:user)) }

      it 'redirects to dashboard (InstructionController gate)' do
        get_show
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end
end
