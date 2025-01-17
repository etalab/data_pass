RSpec.describe 'API: Authorization requests', type: :request do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:, resource_owner_id: user.id) }

  describe 'index' do
    subject(:get_index) do
      get '/api/v1/demandes', headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when there is at least one authorization request associated to one of the user developer role' do
      let!(:valid_authorization_request) { create(:authorization_request, :api_entreprise) }
      let!(:invalid_authorization_request) { create(:authorization_request, :api_particulier) }

      it 'reponds OK with data' do
        get_index

        expect(response.status).to eq(200)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq(valid_authorization_request.id)
      end
    end
  end

  describe 'show' do
    subject(:get_show) do
      get "/api/v1/demandes/#{id}", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    let(:id) { authorization_request.id }

    context 'with valid authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise) }

      it 'responds OK with data' do
        get_show

        expect(response.status).to eq(200)
        expect(response.parsed_body['id']).to eq(authorization_request.id)
      end
    end

    context 'with invalid authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }

      it 'responds 404' do
        get_show

        expect(response.status).to eq(404)
      end
    end
  end
end
