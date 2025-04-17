RSpec.describe 'API: Authorization requests' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:) }

  describe 'index' do
    subject(:get_index) do
      get '/api/v1/demandes', headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when there is not a developer role associated to the user' do
      it 'responds with an empty array' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context 'when there is at least one authorization request associated to one of the user developer role' do
      let!(:valid_draft_authorization_request) { create(:authorization_request, :api_entreprise) }
      let!(:valid_revoked_authorization_request) { create(:authorization_request, :api_entreprise, :revoked) }
      let!(:invalid_authorization_request) { create(:authorization_request, :api_particulier) }

      it 'reponds OK with data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(2)
        expect(response.parsed_body[0]['id']).to eq(valid_draft_authorization_request.id)
      end

      it 'returns only requests with the given state' do
        get '/api/v1/demandes?state[]=revoked', headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq(valid_revoked_authorization_request.id)
      end
    end
  end

  describe 'show' do
    subject(:get_show) do
      get "/api/v1/demandes/#{id}", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    let(:id) { authorization_request.id }

    context 'when the user is a developer for the authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise) }

      it 'responds OK with data' do
        get_show

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['id']).to eq(authorization_request.id)
      end
    end

    context 'when the user is not a developer for the authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }

      it 'responds 404' do
        get_show

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
