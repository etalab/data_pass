RSpec.describe 'Session cookie after the ProConnect dirigeant journey' do
  let(:siret) { '32816124500027' }
  let(:organization) { create(:organization, siret:) }
  let(:user) { create(:user, skip_organization_creation: true) }
  let(:return_to) { '/demandes/registre/nouveau' }
  let(:browser_cookie_size_limit) { 4_096 }
  let(:claims_bringing_the_jwt_to_about_1_2_kb) { { padding: SecureRandom.alphanumeric(300) } }
  let(:userinfo) do
    JSON::JWT.new(
      sub: user.external_id,
      email: user.email,
      given_name: user.given_name,
      usual_name: user.family_name,
      siret:,
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
    user.add_to_organization(organization, current: true, verified: true)
    stub_proconnect_oidc_endpoints(id_token: nil, userinfo:)
  end

  def stub_token_endpoint(nonce:, acr:)
    stub_proconnect_json(:post, '/token', {
      access_token: realistic_token,
      id_token: proconnect_signed_id_token({ sub: user.external_id, acr:, amr: %w[pop mfa], nonce:, **claims_bringing_the_jwt_to_about_1_2_kb }),
      refresh_token: realistic_token
    })
  end

  def realistic_token
    proconnect_signed_id_token({ sub: user.external_id, **claims_bringing_the_jwt_to_about_1_2_kb })
  end

  def sign_in_then_chain_the_dirigeant_certification
    sign_in_params = proconnect_authorization_params('/auth/proconnect', parcours: 'dirigeant', return_to:)
    stub_token_endpoint(nonce: sign_in_params['nonce'], acr: 'eidas1-mfa')
    get '/auth/proconnect/callback', params: { code: 'sign-in-code', state: sign_in_params['state'] }
    follow_redirect!

    Rack::Utils.parse_query(URI(response.location).query)
  end

  def return_from_the_dirigeant_certification
    dirigeant_params = sign_in_then_chain_the_dirigeant_certification
    stub_token_endpoint(nonce: dirigeant_params['nonce'], acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE)
    get '/auth/proconnect_dirigeant/callback', params: { code: 'dirigeant-code', state: dirigeant_params['state'] }
  end

  def session_cookie_size
    response.headers['Set-Cookie'].to_s.split("\n").find { |cookie| cookie.include?('_session=') }.to_s.bytesize
  end

  it 'certifies the dirigeant and sends them back to the page of origin' do
    return_from_the_dirigeant_certification

    expect(response).to redirect_to(return_to)
    expect(flash[:dirigeant_verification]).to include('status' => 'success')
  end

  it 'keeps in the flash only the details displayed on the verification page' do
    return_from_the_dirigeant_certification

    expect(flash[:dirigeant_verification]['details'].keys).to match_array(%w[siren siret acr amr verified_at])
  end

  it 'keeps the session cookie below the 4 KB browser limit' do
    return_from_the_dirigeant_certification

    expect(session_cookie_size).to be_between(1, browser_cookie_size_limit)
  end

  it 'keeps only the id_token among the ProConnect tokens' do
    return_from_the_dirigeant_certification

    expect(session['omniauth.pc.id_token']).to be_present
    expect(session.to_hash.keys).not_to include('omniauth.pc.access_token', 'omniauth.pc.refresh_token')
  end
end
