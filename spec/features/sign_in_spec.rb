RSpec.describe 'Sign in through MonComptePro' do
  subject(:connect_user) do
    visit root_path

    click_button 'login_mon_compte_pro'
  end

  before do
    OmniAuth.config.mock_auth[:mon_compte_pro] = OmniAuth::AuthHash.new({
      'provider' => :mon_compte_pro,
      'uid' => '1',
      'info' => {
        'sub' => '1',
        'email' => 'user@yopmail.com',
        'email_verified' => true,
        'family_name' => 'User',
        'given_name' => 'Jean',
        'updated_at' => DateTime.now.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
        'job' => 'International knowledge practice leader',
        'phone_number' => '0123456789',
        'phone_number_verified' => false,
        'label' => 'Commune de nantes - Mairie',
        'siret' => '21440109300015',
        'is_collectivite_territoriale' => true,
        'is_commune' => true,
        'is_external' => false,
        'is_service_public' => true
      },
      credentials: {
        'token' => 'token',
        'expires_at' => 1.hour.from_now.to_i,
        'expires' => true
      }
    })
  end

  after do
    OmniAuth.config.mock_auth[:mon_compte_pro] = nil
  end

  it 'logs user, redirect to the dashboard and displays his name' do
    connect_user

    expect(page).to have_current_path(dashboard_path, ignore_query: true)
    expect(page).to have_content('User Jean')
  end
end
