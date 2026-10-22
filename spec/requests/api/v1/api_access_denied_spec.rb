RSpec.describe 'API: access denied responses' do
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:) }
  let(:token) { create(:access_token, application:, scopes: token_scopes) }
  let(:token_scopes) { 'public submit_authorizations' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:data_provider) do
    slug = AuthorizationDefinition.find('api_entreprise').provider_slug
    DataProvider.find_by(slug:) || create(:data_provider, slug:)
  end

  before do
    stub_const('TestAPIAccessController', Class.new(API::V1Controller) do
      before_action -> { doorkeeper_authorize! :submit_authorizations }

      def index
        authorize AuthorizationDefinition.find('api_entreprise'), :submit?, policy_class: APIAccessPolicy
        head :no_content
      end

      def other_policy
        authorize DataProvider.new, :index?, policy_class: DataProviderPolicy
        head :no_content
      end
    end)

    Rails.application.reload_routes_unless_loaded
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get '/api/v1/test-api-access', to: 'test_api_access#index'
      get '/api/v1/test-other-policy', to: 'test_api_access#other_policy'
    end
  end

  after do
    Rails.application.routes.disable_clear_and_finalize = false
    Rails.application.reload_routes!
  end

  def error
    response.parsed_body['errors'].first
  end

  context 'when the token does not carry the scope' do
    let(:token_scopes) { 'public read_authorizations' }

    it 'answers a generic 403 that mentions no provider and asks for a new token' do
      get '/api/v1/test-api-access', headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(error).to include('status' => '403', 'title' => 'Droit API manquant')
      expect(error['detail']).to include('nouveau jeton')
      expect(error['detail']).not_to include('fournisseur')
    end
  end

  context 'when an existing endpoint is called with a token missing its scope' do
    let(:token_scopes) { 'public' }

    it 'answers 403 with the same generic message, not the per-right one' do
      get '/api/v1/webhooks/1/attempts', headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(error['detail']).to include('nouveau jeton')
      expect(error['detail']).not_to include('soumettre')
    end
  end

  context 'when another policy refuses the call' do
    it 'answers a generic 403 instead of a 500' do
      get '/api/v1/test-other-policy', headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(error['detail']).to eq(I18n.t('api_errors.api_access_denied.detail.default'))
    end
  end

  context 'when the token carries the scope but the grant is missing' do
    it 'answers the explicit 403 for the right that is missing' do
      get '/api/v1/test-api-access', headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(error).to include('status' => '403', 'title' => 'Droit API manquant')
      expect(error['detail']).to include('soumettre')
    end
  end

  context 'when the token carries the scope and the grant is active' do
    let!(:grant) { create(:api_access_grant, oauth_application: application, data_provider:) }

    it 'lets the call through' do
      get '/api/v1/test-api-access', headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it 'cuts access immediately when the grant is revoked, with the same token' do
      grant.revoke!(by_email: 'admin@example.com', reason: 'Retrait')

      get '/api/v1/test-api-access', headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end
end
