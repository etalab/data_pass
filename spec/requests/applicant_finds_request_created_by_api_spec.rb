RSpec.describe 'Applicant finds a request created through the API' do
  let(:developer) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: developer) }
  let(:write_token) { create(:access_token, application:, scopes: 'public write_authorizations') }
  let(:applicant_email) { 'agent@mairie.fr' }
  let(:siret) { '21920023500014' }

  let(:api_params) do
    {
      demande: {
        form_uid: 'api-entreprise',
        applicant: { email: applicant_email, given_name: 'Jean', family_name: 'Dupont' },
        organization: { siret: },
        data: { intitule: 'Migration éditeur' }
      }
    }
  end

  before(:all) do
    Bullet.enable = false
  end

  after(:all) do
    Bullet.enable = true
  end

  after { OmniAuth.config.mock_auth[:proconnect] = nil }

  def create_request_through_api
    post '/api/v1/demandes', params: api_params, headers: { 'Authorization' => "Bearer #{write_token.token}" }
    AuthorizationRequest.find(response.parsed_body['id'])
  end

  def proconnect_payload(email:)
    identity_provider = IdentityProvider.where(name: 'DGFIP').first

    build(:proconnect_omniauth_payload, siret:, data_identity_id: identity_provider.id).tap do |payload|
      payload['extra']['raw_info']['email'] = email
      payload['credentials'] = { 'id_token' => JSON::JWT.new(amr: ['mfa'], exp: 1.hour.from_now.to_i).to_s }
    end
  end

  def sign_in_through_proconnect(email:)
    OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(proconnect_payload(email:))

    get '/auth/proconnect/callback'
  end

  context 'when the applicant signs in with ProConnect for the first time' do
    it 'reuses the account created through the API instead of creating a duplicate' do
      create_request_through_api

      expect { sign_in_through_proconnect(email: applicant_email) }.not_to change(User, :count)

      expect(User.find_by!(email: applicant_email).external_id).to be_present
    end

    it 'shows the request on the dashboard' do
      create_request_through_api

      sign_in_through_proconnect(email: applicant_email)
      get dashboard_show_path(id: 'demandes')

      expect(response.body).to include('Migration éditeur')
    end

    it 'shows the authorization once the request is validated' do
      authorization_request = create_request_through_api
      authorization_request.update_columns(state: 'validated')
      authorization = create(:authorization, request: authorization_request)

      sign_in_through_proconnect(email: applicant_email)
      get dashboard_show_path(id: 'habilitations')

      expect(response.body).to include(authorization_path(authorization))
    end
  end

  context 'when the applicant already had a DataPass account' do
    let!(:existing_user) { create(:user, email: applicant_email, external_id: 'existing-sub') }

    it 'attaches the request to the existing account' do
      authorization_request = create_request_through_api

      expect(authorization_request.applicant).to eq(existing_user)
    end
  end

  context 'when the applicant signs in with another email' do
    it 'does not show the request' do
      create_request_through_api

      sign_in_through_proconnect(email: 'agent.perso@example.com')
      get dashboard_show_path(id: 'demandes')

      expect(response.body).not_to include('Migration éditeur')
    end
  end
end
