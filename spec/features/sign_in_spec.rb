RSpec.describe 'Sign in through MonComptePro' do
  subject(:connect_user) do
    visit root_path

    click_button 'login_mon_compte_pro'
  end

  before do
    OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
      provider: :mon_compte_pro,
      uid: '1',
      info: attributes_for(:mon_compte_pro_payload),
      credentials: {
        token: 'token',
        expires_at: 1.hour.from_now.to_i,
        expires: true
      }
    })
  end

  after do
    OmniAuth.config.mock_auth[:mon_compte_pro] = nil
  end

  it 'logs user, redirect to the dashboard and displays his email' do
    connect_user

    expect(page).to have_current_path(dashboard_path, ignore_query: true)
    expect(page).to have_content(User.last.email)
  end
end
