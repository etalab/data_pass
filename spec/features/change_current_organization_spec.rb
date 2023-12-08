RSpec.describe 'Change current organization' do
  subject(:change_current_organization) do
    visit dashboard_path

    click_button 'change_current_organization'
  end

  let(:user) { create(:user) }

  before do
    sign_in(user)

    OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
      provider: :mon_compte_pro,
      uid: user.external_id,
      info: attributes_for(:mon_compte_pro_payload, email: user.email, sub: user.external_id),
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

  it 'changes current organization and displays success' do
    expect {
      change_current_organization
    }.to change { user.reload.current_organization }

    expect(page).to have_css('.fr-alert')
  end
end
