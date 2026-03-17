RSpec.describe 'Admin::DataProviders' do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in(admin)
  end

  describe 'GET /admin/fournisseurs-donnees' do
    subject(:get_index) do
      get admin_data_providers_path
      response
    end

    let!(:data_provider) { create(:data_provider) }

    it { is_expected.to have_http_status(:ok) }

    it 'lists data providers' do
      get_index
      expect(response.body).to include(data_provider.name)
    end

    context 'when user is not admin' do
      before { sign_in(create(:user)) }

      it_behaves_like 'an unauthorized access'
    end
  end

  describe 'GET /admin/fournisseurs-donnees/new' do
    subject(:get_new) do
      get new_admin_data_provider_path
      response
    end

    it { is_expected.to have_http_status(:ok) }

    context 'when user is not admin' do
      before { sign_in(create(:user)) }

      it_behaves_like 'an unauthorized access'
    end
  end

  describe 'POST /admin/fournisseurs-donnees' do
    subject(:create_data_provider) do
      post admin_data_providers_path, params: { data_provider: params }

      response
    end

    context 'with valid params' do
      let(:params) { { name: 'Mon API', link: 'https://mon-api.fr' } }

      it { is_expected.to redirect_to(admin_data_providers_path) }

      it 'creates a DataProvider' do
        expect { create_data_provider }.to change(DataProvider, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:params) { { name: '', link: '' } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it 'does not create a DataProvider' do
        expect { create_data_provider }.not_to change(DataProvider, :count)
      end

      it 'renders the new form with errors' do
        create_data_provider
        expect(response.body).to include('fr-alert--error')
      end
    end

    context 'when user is not admin' do
      let(:params) { { name: 'Mon API', link: 'https://mon-api.fr' } }

      before { sign_in(create(:user)) }

      it_behaves_like 'an unauthorized access'
    end
  end

  describe 'GET /admin/fournisseurs-donnees/:id/edit' do
    subject(:get_edit) do
      get edit_admin_data_provider_path(data_provider)
      response
    end

    let(:data_provider) { create(:data_provider) }

    it { is_expected.to have_http_status(:ok) }

    context 'when user is not admin' do
      before { sign_in(create(:user)) }

      it_behaves_like 'an unauthorized access'
    end
  end

  describe 'PATCH /admin/fournisseurs-donnees/:id' do
    subject(:update_data_provider) do
      patch admin_data_provider_path(data_provider), params: { data_provider: params }
      response
    end

    let(:data_provider) { create(:data_provider) }

    context 'with valid params' do
      let(:params) { { name: 'Nouveau Nom', link: 'https://nouveau.fr' } }

      it { is_expected.to redirect_to(admin_data_providers_path) }

      it 'updates the DataProvider' do
        expect { update_data_provider }.to change { data_provider.reload.name }.to('Nouveau Nom')
      end
    end

    context 'with invalid params' do
      let(:params) { { name: '', link: '' } }

      it { is_expected.to have_http_status(:unprocessable_content) }

      it 'does not update the DataProvider' do
        expect { update_data_provider }.not_to change { data_provider.reload.name }
      end
    end

    context 'when user is not admin' do
      let(:params) { { name: 'Nouveau Nom', link: 'https://nouveau.fr' } }

      before { sign_in(create(:user)) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
