RSpec.describe 'GET /auth/proconnect_dirigeant/callback failures' do
  subject(:callback) do
    get '/auth/proconnect_dirigeant/callback', params: callback_params
  end

  let(:authorization_params) { proconnect_authorization_params('/auth/proconnect_dirigeant') }
  let(:id_token) { proconnect_signed_id_token({ sub: 'sub', nonce: 'replayed-nonce' }) }
  let(:userinfo) { JSON::JWT.new(sub: 'sub').to_s }

  around do |example|
    OmniAuth.config.test_mode = false
    example.run
  ensure
    OmniAuth.config.test_mode = true
  end

  before { stub_proconnect_oidc_endpoints(id_token:, userinfo:) }

  context 'when ProConnect returns an error' do
    let(:callback_params) { { error: 'invalid_request', state: authorization_params['state'] } }

    it 'fails without exchanging a code' do
      callback

      expect(response).to redirect_to(%r{\A/auth/failure\?message=proconnect_error&strategy=proconnect_dirigeant})
      expect(a_request(:post, 'https://test.proconnect.gouv.fr/token')).not_to have_been_made
    end
  end

  context 'when ProConnect returns an error for a certification started from another page' do
    let(:authorization_params) { proconnect_authorization_params('/auth/proconnect_dirigeant', return_to:) }
    let(:callback_params) { { error: 'access_denied', state: authorization_params['state'] } }
    let(:return_to) { '/demandes/registre/nouveau' }

    it 'sends the user back to that page with the failure' do
      callback
      follow_redirect!

      expect(response).to redirect_to(return_to)
      expect(flash[:dirigeant_verification]).to include('status' => 'failure', 'reason' => 'proconnect_error')
    end

    context 'when the page belongs to another host' do
      let(:return_to) { 'https://example.com/demandes' }

      it 'sends the user to the verification page' do
        callback
        follow_redirect!

        expect(response).to redirect_to(dirigeant_verification_path)
      end
    end
  end

  context 'when the state comes from the sign in flow' do
    let(:callback_params) { { code: 'code', state: proconnect_authorization_params('/auth/proconnect')['state'] } }

    it 'fails' do
      callback

      expect(response).to redirect_to(%r{\A/auth/failure\?message=csrf_detected&strategy=proconnect_dirigeant})
    end
  end

  context 'when the nonce does not match' do
    let(:callback_params) { { code: 'code', state: authorization_params['state'] } }

    it 'fails' do
      callback

      expect(response).to redirect_to(%r{\A/auth/failure\?message=invalid_id_token&strategy=proconnect_dirigeant})
    end
  end
end
