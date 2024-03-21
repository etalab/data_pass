RSpec.describe 'Dashboard' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'invalid id' do
    it 'redirects to /moi' do
      get dashboard_show_path(id: 'invalid')

      expect(response).to redirect_to(dashboard_show_path(id: 'moi'))
    end
  end
end
