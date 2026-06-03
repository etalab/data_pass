RSpec.describe 'Instruction::DataProviders' do
  let!(:dgfip) { create(:data_provider, :dgfip) }
  let!(:dinum) { create(:data_provider, :dinum) }

  describe 'GET /instruction/fournisseurs-donnees' do
    subject(:get_index) do
      get instruction_data_providers_path
      response
    end

    context 'when user is admin' do
      before { sign_in(create(:user, :admin)) }

      it { is_expected.to have_http_status(:ok) }

      it 'lists every provider' do
        get_index
        expect(response.body).to include(dgfip.name)
        expect(response.body).to include(dinum.name)
      end
    end

    context 'when user is FD reporter scoped to one provider' do
      before { sign_in(create(:user, :fd_reporter, data_provider_slugs: %w[dgfip])) }

      it { is_expected.to have_http_status(:ok) }

      it 'lists only the accessible provider' do
        get_index
        expect(response.body).to include(dgfip.name)
        expect(response.body).not_to include(dinum.name)
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
end
