RSpec.describe 'Dashboard' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'invalid id' do
    it 'redirects to /moi' do
      get dashboard_show_path(id: 'invalid')

      expect(response).to redirect_to(dashboard_show_path(id: 'demandes'))
    end
  end

  describe 'demandes tab' do
    it 'loads successfully and uses DashboardDemandesFacade' do
      get dashboard_show_path(id: 'demandes')

      expect(response).to have_http_status(:success)
      expect(assigns(:facade)).to be_a(DashboardDemandesFacade)
      expect(assigns(:facade).tabs).to be_present
      expect(assigns(:facade).search_engine).to be_present
    end
  end

  describe 'habilitations tab' do
    it 'loads successfully and uses DashboardHabilitationsFacade' do
      get dashboard_show_path(id: 'habilitations')

      expect(response).to have_http_status(:success)
      expect(assigns(:facade)).to be_a(DashboardHabilitationsFacade)
      expect(assigns(:facade).tabs).to be_present
      expect(assigns(:facade).search_engine).to be_present
    end
  end
end
