RSpec.describe 'API: Credentials' do
  context 'when unauthorized' do
    it 'returns unauthorized' do
      get '/api/v1/me'

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['errors']).to include(
        hash_including(
          status: '401'
        )
      )
      assert_request_schema_confirm
      assert_schema_conform
    end
  end

  context 'when authorized' do
    let(:user) { create(:user) }
    let(:application) { create(:oauth_application, owner: user) }
    let(:access_token) { create(:access_token, application:) }

    it 'returns the current user' do
      get '/api/v1/me', params: {}, headers: { 'Authorization' => "Bearer #{access_token.token}" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(user.attributes.slice('id', 'email', 'family_name', 'given_name', 'job_title'))
      assert_request_schema_confirm
      assert_schema_conform
    end
  end
end
