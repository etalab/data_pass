RSpec.describe 'GET /auth/proconnect/callback' do
  subject(:callback) do
    get '/auth/proconnect/callback', params: callback_params
  end

  let(:authorization_params) { proconnect_authorization_params('/auth/proconnect') }
  let(:callback_params) { { code: 'authorization-code', state: authorization_params['state'] } }
  let(:user) { create(:user) }
  let(:acr) { 'eidas1-mfa' }
  let(:id_token_claims) { { sub: user.external_id, acr:, nonce: authorization_params['nonce'] } }
  let(:id_token) { proconnect_signed_id_token(id_token_claims) }
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

    stub_proconnect_oidc_endpoints(id_token:, userinfo:)
  end

  shared_examples 'a rejected ProConnect callback' do |failure_type|
    it 'redirects to the failure endpoint without signing the user in' do
      callback

      expect(response).to redirect_to(%r{\A/auth/failure\?message=#{failure_type}&strategy=proconnect})
      expect(session[:user_id]).to be_nil
    end

    it 'reports the failure to Sentry' do
      callback

      expect(Sentry).to have_received(:capture_message).with(
        'OmniAuth authentication failure',
        level: :warning,
        extra: hash_including(strategy: 'proconnect', type: failure_type)
      )
    end
  end

  context 'when ProConnect performed MFA' do
    it 'signs the user in' do
      callback

      expect(response).to redirect_to(dashboard_path)
    end

    it 'consumes the nonce' do
      callback

      expect(session['omniauth.nonce']).to be_nil
    end

    it 'keeps only the id_token in the session, for the ProConnect logout' do
      stub_proconnect_json(:post, '/token', { access_token: 'access-token', id_token:, refresh_token: 'refresh-token' })

      callback

      expect(session['omniauth.pc.id_token']).to eq(id_token)
      expect(session.to_hash.keys).not_to include('omniauth.pc.access_token', 'omniauth.pc.refresh_token')
    end

    it 'logs out of ProConnect with the id_token kept in the session' do
      callback
      get '/auth/proconnect/logout'

      expect(Rack::Utils.parse_query(URI(response.location).query)).to include('id_token_hint' => id_token)
    end

    it 'fetches the userinfo with the access token' do
      callback

      expect(a_request(:get, 'https://test.proconnect.gouv.fr/userinfo').with(headers: { 'Authorization' => 'Bearer access-token' })).to have_been_made
    end
  end

  context 'when ProConnect did not perform MFA' do
    let(:acr) { 'eidas1' }

    it 'redirects to the sign-in page without signing the user in' do
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
    let(:acr) { nil }

    it 'does not sign the user in' do
      callback

      expect(response).to redirect_to(connexion_path)
      expect(session[:user_id]).to be_nil
    end
  end

  context 'when ProConnect returns an error' do
    let(:callback_params) do
      {
        error: 'invalid_request',
        error_description: 'authentication aborted due to a technical error on the authorization server',
        state: authorization_params['state']
      }
    end

    it_behaves_like 'a rejected ProConnect callback', :proconnect_error

    it 'does not try to exchange a code' do
      callback

      expect(a_request(:post, 'https://test.proconnect.gouv.fr/token')).not_to have_been_made
    end
  end

  context 'when the state does not match' do
    let(:callback_params) { { code: 'authorization-code', state: 'forged-state' } }

    it_behaves_like 'a rejected ProConnect callback', :csrf_detected
  end

  context 'when the token exchange fails' do
    before do
      stub_request(:post, 'https://test.proconnect.gouv.fr/token').to_return(status: 400)
    end

    it_behaves_like 'a rejected ProConnect callback', :token_exchange_failed
  end

  context 'when the id_token is signed with an unknown key' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims, key: OpenSSL::PKey::RSA.generate(2048).to_jwk) }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token is signed with the client secret' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims, key: ProConnectConfig.client_secret, algorithm: :HS256) }

    it 'signs the user in' do
      callback

      expect(response).to redirect_to(dashboard_path)
    end
  end

  context 'when the id_token is signed with another secret' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims, key: 'another-secret', algorithm: :HS256) }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token is signed in HS256 with the provider public key' do
    let(:id_token) do
      proconnect_signed_id_token(id_token_claims, key: proconnect_signing_key.to_key.public_to_pem, algorithm: :HS256)
    end

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token is not signed' do
    let(:id_token) { JSON::JWT.new(id_token_claims).to_s }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token nonce does not match' do
    let(:id_token_claims) { { sub: user.external_id, acr:, nonce: 'replayed-nonce' } }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token is issued for another client' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims, client_id: 'another-client') }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token is expired' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims.merge(exp: 1.minute.ago.to_i)) }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when the id_token expired a few seconds ago' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims.merge(exp: 5.seconds.ago.to_i)) }

    it 'tolerates the clock skew and signs the user in' do
      callback

      expect(response).to redirect_to(dashboard_path)
    end
  end

  context 'when the id_token signature check is switched off' do
    before { Setting.set(:proconnect_id_token_signature_check, 'false') }

    context 'with an id_token signed with an unknown key' do
      let(:id_token) { proconnect_signed_id_token(id_token_claims, key: OpenSSL::PKey::RSA.generate(2048).to_jwk) }

      it 'signs the user in' do
        callback

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context 'with an id_token whose nonce does not match' do
      let(:id_token_claims) { { sub: user.external_id, acr:, nonce: 'replayed-nonce' } }

      it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
    end

    context 'with an id_token issued for another client' do
      let(:id_token) { proconnect_signed_id_token(id_token_claims, client_id: 'another-client') }

      it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
    end
  end

  context 'when the id_token comes from another issuer' do
    let(:id_token) { proconnect_signed_id_token(id_token_claims.merge(iss: 'https://evil.example')) }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end

  context 'when userinfo and id_token disagree on the sub' do
    let(:id_token_claims) { { sub: 'another-sub', acr:, nonce: authorization_params['nonce'] } }

    it_behaves_like 'a rejected ProConnect callback', :invalid_id_token
  end
end
