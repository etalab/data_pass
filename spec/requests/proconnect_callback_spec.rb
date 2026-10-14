RSpec.describe 'GET /auth/proconnect/callback' do
  subject(:callback) do
    post '/auth/proconnect'
    state = Rack::Utils.parse_query(URI(response.location).query)['state']

    get '/auth/proconnect/callback', params: { code: 'authorization-code', state: }
  end

  let(:user) { create(:user) }
  let(:id_token) { JSON::JWT.new(acr:).to_s }
  let(:userinfo) do
    JSON::JWT.new(
      sub: user.external_id,
      email: user.email,
      given_name: user.given_name,
      usual_name: user.family_name,
      siret: user.current_organization.siret,
      idp_id: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID
    ).to_s
  end

  around do |example|
    OmniAuth.config.test_mode = false
    example.run
  ensure
    OmniAuth.config.test_mode = true
  end

  before do
    allow(Sentry).to receive(:capture_message)

    stub_request(:get, %r{.well-known/openid-configuration$}).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        authorization_endpoint: 'https://test.proconnect.gouv.fr/authorize',
        token_endpoint: 'https://test.proconnect.gouv.fr/token',
        userinfo_endpoint: 'https://test.proconnect.gouv.fr/userinfo'
      }.to_json
    )
    stub_request(:post, 'https://test.proconnect.gouv.fr/token').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { access_token: 'access-token', id_token: }.to_json
    )
    stub_request(:get, 'https://test.proconnect.gouv.fr/userinfo').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/jwt' },
      body: userinfo
    )
  end

  context 'when ProConnect performed MFA' do
    let(:acr) { 'eidas1-mfa' }

    it 'signs the user in' do
      callback

      expect(response).to redirect_to(dashboard_path)
    end
  end

  context 'when ProConnect did not perform MFA' do
    let(:acr) { 'eidas1' }

    it 'redirects to the home page without signing the user in' do
      callback
      follow_redirect!

      expect(response.body).to include('double authentification')
      expect(session[:user_id]).to be_nil
    end

    it 'reports the rejected sign in to Sentry' do
      callback

      expect(Sentry).to have_received(:capture_message).with(
        'ProConnect sign in rejected: acr is not MFA',
        level: :error,
        extra: { acr: 'eidas1', identity_provider_uid: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID }
      )
    end
  end

  context 'when the id_token has no acr' do
    let(:id_token) { JSON::JWT.new({}).to_s }

    it 'does not sign the user in' do
      callback

      expect(response).to redirect_to(root_path)
    end
  end
end
