RSpec.describe 'API: Authorizations' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:, resource_owner_id: user.id) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe 'show' do
    subject(:get_show) do
      get "/api/v1/habilitations/#{authorization.id}", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    let!(:authorization) { create(:authorization, request: authorization_request) }

    context 'when the authorization exists and user has access to it' do
      it 'responds OK with data' do
        get_show

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['id']).to eq(authorization.id)
        expect(response.parsed_body['authorization_request_class']).to eq(authorization.authorization_request_class)
        expect(response.parsed_body['organisation']).to be_present
        expect(response.parsed_body['organisation']['siret']).to eq(authorization.organization.siret)
      end
    end

    context 'when the authorization does not exist' do
      subject(:get_show) do
        get '/api/v1/habilitations/0', headers: { 'Authorization' => "Bearer #{access_token.token}" }
      end

      it 'responds 404' do
        get_show

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'index' do
    subject(:get_index) do
      get '/api/v1/habilitations', headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when there are authorizations the user has access to' do
      let!(:authorizations) { create_list(:authorization, 3, request: authorization_request) }

      it 'responds OK with data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(3)
        expect(response.parsed_body.pluck('id')).to match_array(authorizations.pluck(:id))
        expect(response.parsed_body.first['organisation']).to be_present
        expect(response.parsed_body.first['organisation']['siret']).to be_present
      end
    end

    context 'with pagination parameters' do
      let!(:authorizations) { create_list(:authorization, 5, request: authorization_request) }

      it 'respects the specified limit' do
        get '/api/v1/habilitations', params: { limit: 3 }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(3)
      end

      it 'respects the offset parameter' do
        get '/api/v1/habilitations', params: { offset: 1 }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(4) # 5 total - 1 offset = 4 remaining
      end
    end

    context 'with state filter' do
      let!(:active_authorizations) { create_list(:authorization, 2, request: authorization_request, state: 'active') }
      let!(:revoked_authorizations) { create_list(:authorization, 3, request: authorization_request, state: 'revoked') }

      it 'filters by single state' do
        get '/api/v1/habilitations', params: { state: 'active' }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(2)
        expect(response.parsed_body.pluck('state')).to all(eq('active'))
      end

      it 'filters by multiple states' do
        get '/api/v1/habilitations', params: { state: %w[active revoked] }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(5)
        expect(response.parsed_body.pluck('state')).to match_array(%w[active active revoked revoked revoked])
      end
    end

    context 'when user has no access to any authorization' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }

      it 'responds OK with empty data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end
  end
end
