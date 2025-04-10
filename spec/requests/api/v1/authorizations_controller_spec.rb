RSpec.describe 'API: Authorizations' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:, resource_owner_id: user.id) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe 'index' do
    subject(:get_index) do
      get "/api/v1/demandes/#{authorization_request.id}/habilitations", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when there are authorizations for the request' do
      let!(:authorization) { create(:authorization, request: authorization_request) }

      it 'responds OK with data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq(authorization.id)
      end
    end

    context 'when there are no authorizations for the request' do
      it 'responds OK with empty data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context 'when the authorization request is invalid' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }

      it 'responds 404' do
        get_index

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
