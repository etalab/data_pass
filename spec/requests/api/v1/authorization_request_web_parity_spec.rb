RSpec.describe 'API: parity with the web rules' do
  let(:developer) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_r2p hubee_dila]) }
  let(:application) { create(:oauth_application, owner: developer) }
  let(:token) { create(:access_token, application:, scopes: 'public read_authorizations write_authorizations') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:siret) { '13002526500013' }
  let(:email) { 'applicant@example.com' }
  let(:existing_applicant) { create(:user, email:) }
  let(:form_uid) { 'api-entreprise' }
  let(:form) { AuthorizationRequestForm.find(form_uid) }
  let(:closed_insee_payload) do
    { 'etablissement' => { 'periodesEtablissement' => [{ 'dateFin' => nil, 'etatAdministratifEtablissement' => 'F' }] } }
  end

  before(:all) do
    Bullet.enable = false
  end

  after(:all) do
    Bullet.enable = true
  end

  def create_by_api
    post '/api/v1/demandes', headers: auth_headers, params: {
      demande: {
        form_uid:,
        applicant: { email:, given_name: 'Jean', family_name: 'Dupont' },
        organization: { siret: },
        data: {}
      }
    }
  end

  def web_policy_allows_creation?
    applicant = User.find_by!(email:)

    AuthorizationRequestFormPolicy.new(UserContext.new(applicant), form).create?
  end

  def error_titles
    response.parsed_body['errors'].pluck('title')
  end

  describe 'creation' do
    context 'when the form cannot be started by an applicant' do
      let(:form_uid) { 'api-r2p-production' }

      let(:siret) { existing_applicant.current_organization.legal_entity_id }

      before { existing_applicant }

      it 'is refused by the web policy and by the API' do
        expect(web_policy_allows_creation?).to be(false)

        create_by_api

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_titles).to eq(['Formulaire non disponible'])
      end
    end

    context 'when the organization is closed' do
      let(:siret) { existing_applicant.current_organization.legal_entity_id }

      before { existing_applicant.current_organization.update!(insee_payload: closed_insee_payload) }

      it 'is refused by the web policy and by the API' do
        expect(web_policy_allows_creation?).to be(false)

        create_by_api

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_titles).to eq(['Organisation fermée'])
      end
    end

    context 'when the definition is unique and a request is already active' do
      let(:form_uid) { 'hubee-dila' }

      let(:siret) { existing_applicant.current_organization.legal_entity_id }

      before do
        create(:authorization_request, :hubee_dila, applicant: existing_applicant, organization: existing_applicant.current_organization)
      end

      it 'is refused by the web policy and by the API' do
        expect(web_policy_allows_creation?).to be(false)

        create_by_api

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_titles).to eq(['Demande déjà existante'])
      end
    end

    context 'when the applicant is banned' do
      before { create(:user, email:, banned_at: Time.zone.now, ban_reason: 'Abus') }

      it 'is refused and creates nothing' do
        expect { create_by_api }.not_to change(AuthorizationRequest, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_titles).to eq(['Demandeur invalide'])
      end
    end

    context 'when a refused creation had provisioned new records' do
      let(:form_uid) { 'api-r2p-production' }

      before { auth_headers }

      it 'leaves no applicant or organization behind' do
        expect { create_by_api }.not_to change { [User.count, Organization.count] }
      end
    end
  end

  describe 'update' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, state) }

    before do
      patch "/api/v1/demandes/#{authorization_request.id}",
        params: { demande: { data: { intitule: 'Modifié' } } },
        headers: auth_headers
    end

    %i[draft changes_requested].each do |editable_state|
      context "when the request is #{editable_state}" do
        let(:state) { editable_state }

        it 'is editable like on the web' do
          expect(AuthorizationRequestPolicy.new(UserContext.new(authorization_request.applicant), authorization_request).update?).to be(true)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    %i[submitted validated refused].each do |locked_state|
      context "when the request is #{locked_state}" do
        let(:state) { locked_state }

        it 'is locked like on the web' do
          expect(AuthorizationRequestPolicy.new(UserContext.new(authorization_request.applicant), authorization_request).update?).to be(false)
          expect(response).to have_http_status(:unprocessable_content)
          expect(error_titles).to eq(['État non modifiable'])
        end

        it 'keeps the data untouched' do
          expect(authorization_request.reload.intitule).not_to eq('Modifié')
        end
      end
    end
  end
end
