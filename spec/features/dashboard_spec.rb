RSpec.describe 'Dashboard' do
  context 'when logged in as a user' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'works' do
      visit dashboard_path

      expect(page).to have_content user.full_name
    end
  end
end
