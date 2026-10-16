RSpec.describe 'Developers::OauthApplications scopes' do
  let(:developer) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

  before { sign_in(developer) }

  it 'never lets a developer give their application an API access scope' do
    post developers_oauth_applications_path, params: {
      doorkeeper_application: { name: 'Application pirate', scopes: 'submit_authorizations validate_authorizations' }
    }

    application = Doorkeeper::Application.find_by!(name: 'Application pirate')

    expect(application.scopes.to_a).to match_array(%w[public read_authorizations read_webhooks])
  end
end
