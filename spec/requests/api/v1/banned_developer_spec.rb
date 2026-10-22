RSpec.describe 'API: banned developer' do
  let(:developer) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: developer) }
  let(:access_token) { create(:access_token, application:, scopes: 'public read_authorizations write_authorizations') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{access_token.token}" } }

  context 'when the developer is not banned' do
    it 'lets the token through' do
      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:ok)
    end
  end

  context 'when the developer was banned after the token was issued' do
    before do
      access_token
      developer.update!(banned_at: Time.zone.now, ban_reason: 'Abus')
    end

    it 'refuses the token on a read endpoint' do
      get '/api/v1/demandes', headers: auth_headers

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body['errors']).to include(hash_including('status' => '403', 'title' => 'Compte banni'))
    end

    it 'refuses the token on the credentials endpoint' do
      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'refuses the token on a write endpoint without creating anything' do
      expect {
        post '/api/v1/demandes', params: { demande: { form_uid: 'api-entreprise' } }, headers: auth_headers
      }.not_to change(AuthorizationRequest, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when the developer is banned and unbanned again' do
    before { developer.update!(banned_at: Time.zone.now, ban_reason: 'Abus') }

    it 'accepts the token again' do
      developer.update!(banned_at: nil, ban_reason: nil)

      get '/api/v1/me', headers: auth_headers

      expect(response).to have_http_status(:ok)
    end
  end

  context 'without any token' do
    it 'still answers unauthorized' do
      get '/api/v1/me'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
