RSpec.describe 'Notification settings of the profile' do
  let(:user) { create(:user, :fd_reporter, data_provider_slugs: %w[dinum]) }

  before { sign_in(user) }

  it 'lists a form whose feature flag is on' do
    get profile_path

    expect(response.body).to include('notifications-registre_wallet-legend')
  end

  it 'hides a form whose feature flag is off' do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with('registre_wallet').and_return(false)

    get profile_path

    expect(response.body).not_to include('notifications-registre_wallet-legend')
  end
end
