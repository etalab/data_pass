RSpec.describe 'API: OAuth Token' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }

  describe 'POST /api/oauth/token' do
    context 'with valid client credentials' do
      let(:params) do
        {
          grant_type: 'client_credentials',
          client_id: application.uid,
          client_secret: application.secret
        }
      end

      it 'returns a valid access token' do
        post '/api/v1/oauth/token', params: params, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include('access_token', 'token_type', 'expires_in', 'created_at')
        expect(response.parsed_body['token_type']).to eq('Bearer')
        assert_request_schema_confirm
        assert_schema_conform(200)
      end
    end

    context 'with invalid client credentials' do
      let(:params) do
        {
          grant_type: 'client_credentials',
          client_id: 'invalid_client_id',
          client_secret: 'invalid_client_secret'
        }
      end

      it 'returns unauthorized error' do
        post '/api/v1/oauth/token', params: params, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to include('error')
        assert_request_schema_confirm
        assert_schema_conform(401)
      end
    end

    context 'with missing parameters' do
      let(:params) do
        {
          grant_type: 'client_credentials'
        }
      end

      it 'returns bad request error' do
        post '/api/v1/oauth/token', params: params, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to include('error')
      end
    end

    context 'with invalid grant type' do
      let(:params) do
        {
          grant_type: 'invalid_grant_type',
          client_id: application.uid,
          client_secret: application.secret
        }
      end

      it 'returns bad request error' do
        post '/api/v1/oauth/token', params: params, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include('error')
        assert_request_schema_confirm
        assert_schema_conform(400)
      end
    end
  end
end
