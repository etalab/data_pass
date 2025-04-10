RSpec.describe 'API: Authorization Request Events' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:, resource_owner_id: user.id) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  describe 'index' do
    subject(:get_index) do
      get "/api/v1/demandes/#{authorization_request.id}/events", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when the user is not a developer for the authorization request' do
      let(:authorization_request) { create(:authorization_request, :api_particulier) }

      it 'responds 404' do
        get_index

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is a developer for the authorization request' do
      context 'when there are events for the request' do
        let!(:event) { create(:authorization_request_event, entity: authorization_request) }

        it 'responds OK with data' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body.count).to eq(1)
          expect(response.parsed_body[0]['id']).to eq(event.id)
        end
      end

      context 'when there are no events for the request' do
        it 'responds OK with empty data' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to be_empty
        end
      end
    end
  end
end
