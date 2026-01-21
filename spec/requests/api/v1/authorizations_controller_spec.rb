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
        expect(response.parsed_body['request_id']).to eq(authorization.request_id)
        expect(response.parsed_body['organisation']).to be_present
        expect(response.parsed_body['organisation']['siret']).to eq(authorization.organization.siret)

        validate_request_and_response!
      end
    end

    context 'when the authorization does not exist' do
      subject(:get_show) do
        get '/api/v1/habilitations/0', headers: { 'Authorization' => "Bearer #{access_token.token}" }
      end

      it 'responds 404' do
        get_show

        expect(response).to have_http_status(:not_found)

        validate_request_and_response!
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
        expect(response.parsed_body.first['request_id']).to be_present
        expect(response.parsed_body.first['organisation']).to be_present
        expect(response.parsed_body.first['organisation']['siret']).to be_present

        validate_request_and_response!
      end
    end

    context 'with pagination parameters' do
      let!(:authorizations) { create_list(:authorization, 5, request: authorization_request) }

      it 'respects the specified limit' do
        get '/api/v1/habilitations', params: { limit: 3 }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(3)

        validate_request_and_response!
      end

      it 'respects the offset parameter' do
        get '/api/v1/habilitations', params: { offset: 1 }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(5 - 1)

        validate_request_and_response!
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

        validate_request_and_response!
      end

      it 'filters by multiple states' do
        get '/api/v1/habilitations', params: { state: %w[active revoked] }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(5)
        expect(response.parsed_body.pluck('state')).to match_array(%w[active active revoked revoked revoked])

        validate_request_and_response!
      end
    end

    context 'with siret filter' do
      let(:target_organization) { create(:organization, siret: '13002526500013') }
      let(:other_organization) { create(:organization, siret: '21920023500014') }
      let(:target_organization_request) { create(:authorization_request, :api_entreprise, organization: target_organization) }
      let(:other_organization_request) { create(:authorization_request, :api_entreprise, organization: other_organization) }
      let!(:target_organization_authorizations) { create_list(:authorization, 2, request: target_organization_request) }
      let!(:other_organization_authorizations) { create_list(:authorization, 3, request: other_organization_request) }

      it 'filters by SIRET' do
        get '/api/v1/habilitations', params: { siret: '13002526500013' }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(2)
        expect(response.parsed_body.pluck('id')).to match_array(target_organization_authorizations.pluck(:id))
        expect(response.parsed_body.first['organisation']['siret']).to eq('13002526500013')

        validate_request_and_response!
      end

      it 'returns empty array when no authorizations match the SIRET' do
        get '/api/v1/habilitations', params: { siret: '99999999999999' }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty

        validate_request_and_response!
      end

      it 'can be combined with state filter' do
        target_organization_authorizations.first.update!(state: 'active')
        target_organization_authorizations.second.update!(state: 'revoked')
        other_organization_authorizations.each { |auth| auth.update!(state: 'active') }

        get '/api/v1/habilitations', params: { siret: '13002526500013', state: 'active' }, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body.first['id']).to eq(target_organization_authorizations.first.id)
        expect(response.parsed_body.first['state']).to eq('active')
        expect(response.parsed_body.first['organisation']['siret']).to eq('13002526500013')

        validate_request_and_response!
      end
    end

    context 'when user has no access to any authorization' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }

      it 'responds OK with empty data' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty

        validate_request_and_response!
      end
    end
  end
end
