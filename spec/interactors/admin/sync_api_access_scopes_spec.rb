RSpec.describe Admin::SyncAPIAccessScopes do
  it 'does nothing when the application of the grant no longer exists' do
    grant = build(:api_access_grant, oauth_application: nil)

    expect(described_class.call(grant:)).to be_a_success
  end
end
