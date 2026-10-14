RSpec.describe 'API: Authorization request history' do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:token) { create(:access_token, application:, scopes: 'public read_authorizations write_authorizations') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:create_params) do
    {
      demande: {
        form_uid: 'api-entreprise',
        applicant: { email: 'new-user@example.com', given_name: 'Jean', family_name: 'Dupont' },
        organization: { siret: '13002526500013' },
        data: { intitule: 'Avant' }
      }
    }
  end

  before(:all) do
    Bullet.enable = false
  end

  after(:all) do
    Bullet.enable = true
  end

  def create_by_api(params = create_params)
    post '/api/v1/demandes', params:, headers: auth_headers
  end

  def update_by_api(authorization_request, data)
    patch "/api/v1/demandes/#{authorization_request.id}", params: { demande: { data: } }, headers: auth_headers
  end

  def api_event(authorization_request, name)
    authorization_request.events_without_bulk_update.find_by(name:)
  end

  def listed_event_names(authorization_request)
    get "/api/v1/demandes/#{authorization_request.id}/events", headers: auth_headers
    response.parsed_body.pluck('name')
  end

  describe 'creation by API' do
    let(:authorization_request) { AuthorizationRequest.last }
    let(:event) { api_event(authorization_request, 'create_by_api') }

    before { create_by_api }

    it 'logs a create_by_api event on the changelog entity' do
      expect(event.entity).to be_a(AuthorizationRequestChangelog)
      expect(event.entity.diff['intitule']).to eq([nil, 'Avant'])
    end

    it 'attributes the event to the owner of the OAuth application' do
      expect(event.user).to eq(user)
    end

    it 'lists the event in the history endpoint' do
      expect(listed_event_names(authorization_request)).to include('create_by_api')
    end
  end

  describe 'update by API' do
    let(:authorization_request) { AuthorizationRequest.last }
    let(:event) { api_event(authorization_request, 'update_by_api') }

    before do
      create_by_api
      update_by_api(authorization_request, { intitule: 'Après' })
    end

    it 'logs an update_by_api event with the before and after values' do
      expect(response).to have_http_status(:ok)
      expect(event.entity).to be_a(AuthorizationRequestChangelog)
      expect(event.entity.diff['intitule']).to eq(%w[Avant Après])
    end

    it 'attributes the event to the owner of the OAuth application' do
      expect(event.user).to eq(user)
    end

    it 'lists both events, most recent first' do
      expect(listed_event_names(authorization_request).grep(/_by_api\z/)).to eq(%w[update_by_api create_by_api])
    end
  end

  describe 'failed API calls' do
    let(:invalid_data) { { nonexistent_field: 'value' } }

    it 'logs nothing and leaves no request behind when creation is rejected' do
      params = create_params.deep_merge(demande: { data: invalid_data })

      expect { create_by_api(params) }.not_to change { [AuthorizationRequestEvent.count, AuthorizationRequest.count] }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'logs nothing when an update is rejected' do
      create_by_api
      authorization_request = AuthorizationRequest.last

      expect { update_by_api(authorization_request, invalid_data) }.not_to change(AuthorizationRequestEvent, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'rendering of the history' do
    let(:authorization_request) { AuthorizationRequest.last }

    before do
      create_by_api
      update_by_api(authorization_request, { intitule: 'Après' })
    end

    it 'renders the create_by_api event' do
      page = render_inline(HistoricalAuthorizationRequestEventComponent.new(authorization_request_event: api_event(authorization_request, 'create_by_api')))

      expect(page).to have_text(/La demande a été créée via l.API/)
    end

    it 'renders the update_by_api event' do
      page = render_inline(HistoricalAuthorizationRequestEventComponent.new(authorization_request_event: api_event(authorization_request, 'update_by_api')))

      expect(page).to have_text(/La demande a été mise à jour via l.API/)
    end
  end
end
