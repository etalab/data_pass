RSpec.describe 'API: Authorization requests write' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:write_token) { create(:access_token, application:, scopes: 'public write_authorizations') }
  let(:read_token) { create(:access_token, application:, scopes: 'public read_authorizations') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{write_token.token}" } }

  before(:all) do
    Bullet.enable = false
  end

  after(:all) do
    Bullet.enable = true
  end

  describe 'POST /api/v1/demandes' do
    subject(:create_request) do
      post '/api/v1/demandes', params:, headers: auth_headers
    end

    let(:params) do
      {
        demande: {
          form_uid: 'api-entreprise',
          applicant: {
            email: 'new-user@example.com',
            given_name: 'Jean',
            family_name: 'Dupont'
          },
          organization: { siret: '13002526500013' },
          data: { intitule: 'Mon projet de test' }
        }
      }
    end

    it 'creates an authorization request and returns 201' do
      expect { create_request }.to change(AuthorizationRequest, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['state']).to eq('draft')
      expect(response.parsed_body['data']['intitule']).to eq('Mon projet de test')
      expect(response.parsed_body['applicant']['email']).to eq('new-user@example.com')
      expect(response.parsed_body['organisation']['siret']).to eq('13002526500013')
    end

    it 'creates a new user without external_id' do
      create_request

      created_user = User.find_by(email: 'new-user@example.com')

      expect(created_user).to be_present
      expect(created_user.external_id).to be_nil
      expect(created_user.given_name).to eq('Jean')
      expect(created_user.family_name).to eq('Dupont')
    end

    it 'creates a new organization and schedules INSEE refresh' do
      create_request

      expect(Organization.find_by(legal_entity_id: '13002526500013')).to be_present
      expect(UpdateOrganizationINSEEPayloadJob).to have_been_enqueued
    end

    it 'creates an unverified link between user and organization' do
      create_request

      org_user = User.find_by(email: 'new-user@example.com')
        .organizations_users
        .find_by(organization: Organization.find_by(legal_entity_id: '13002526500013'))

      expect(org_user.verified).to be(false)
      expect(org_user.identity_federator).to eq('unknown')
    end

    it 'creates a create_by_api event' do
      create_request

      ar = AuthorizationRequest.last
      event = ar.events_without_bulk_update.find_by(name: 'create_by_api')

      expect(event).to be_present
    end

    context 'with existing user and organization' do
      let!(:existing_user) { create(:user, email: 'new-user@example.com') }
      let!(:existing_org) { create(:organization, legal_entity_id: '13002526500013', legal_entity_registry: 'insee_sirene') }

      it 'reuses existing user and organization' do
        write_token
        user_count = User.count
        org_count = Organization.count

        expect { create_request }.to change(AuthorizationRequest, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(User.count).to eq(user_count)
        expect(Organization.count).to eq(org_count)
      end
    end

    context 'with type instead of form_uid' do
      let(:params) do
        {
          demande: {
            type: 'api_entreprise',
            applicant: { email: 'user@example.com', given_name: 'A', family_name: 'B' },
            organization: { siret: '13002526500013' },
            data: {}
          }
        }
      end

      it 'resolves the default form and creates the request' do
        create_request

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid data keys' do
      let(:params) do
        {
          demande: {
            form_uid: 'api-entreprise',
            applicant: { email: 'user@example.com', given_name: 'A', family_name: 'B' },
            organization: { siret: '13002526500013' },
            data: { nonexistent_field: 'value' }
          }
        }
      end

      it 'returns 422 with the invalid key in errors' do
        create_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors'].first['source']['pointer']).to eq('/data/nonexistent_field')
      end

      it 'does not create the applicant or the organization' do
        write_token
        user_count = User.count
        org_count = Organization.count

        create_request

        expect(User.count).to eq(user_count)
        expect(Organization.count).to eq(org_count)
      end
    end

    context 'without write_authorizations scope' do
      let(:auth_headers) { { 'Authorization' => "Bearer #{read_token.token}" } }

      it 'returns an error' do
        create_request

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with type outside developer_roles' do
      let(:params) do
        {
          demande: {
            form_uid: 'api-particulier',
            applicant: { email: 'user@example.com', given_name: 'A', family_name: 'B' },
            organization: { siret: '13002526500013' },
            data: {}
          }
        }
      end

      it 'returns 403' do
        create_request

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid form_uid' do
      let(:params) do
        {
          demande: {
            form_uid: 'nonexistent-form',
            applicant: { email: 'user@example.com', given_name: 'A', family_name: 'B' },
            organization: { siret: '13002526500013' },
            data: {}
          }
        }
      end

      it 'returns 422' do
        create_request

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with missing applicant email' do
      let(:params) do
        {
          demande: {
            form_uid: 'api-entreprise',
            applicant: { given_name: 'Jean', family_name: 'Dupont' },
            organization: { siret: '13002526500013' },
            data: { intitule: 'Mon projet' }
          }
        }
      end

      it 'returns 422 instead of 500' do
        create_request

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create a user' do
        write_token

        expect { create_request }.not_to change(User, :count)
      end
    end

    context 'when the applicant is already a verified member of the organization' do
      let!(:existing_user) { create(:user, email: 'new-user@example.com') }
      let!(:existing_org) { create(:organization, legal_entity_id: '13002526500013', legal_entity_registry: 'insee_sirene') }

      before do
        existing_user.add_to_organization(
          existing_org,
          identity_federator: 'pro_connect',
          identity_provider_uid: 'pc-uid-42',
          verified: true
        )
      end

      it 'preserves the verified link identity_federator' do
        create_request

        org_user = existing_user.organizations_users.find_by(organization: existing_org)
        expect(org_user.identity_federator).to eq('pro_connect')
      end

      it 'preserves the verified link identity_provider_uid' do
        create_request

        org_user = existing_user.organizations_users.find_by(organization: existing_org)
        expect(org_user.identity_provider_uid).to eq('pc-uid-42')
      end

      it 'keeps the link verified' do
        create_request

        org_user = existing_user.organizations_users.find_by(organization: existing_org)
        expect(org_user.verified).to be(true)
      end
    end
  end

  describe 'PATCH /api/v1/demandes/:id' do
    subject(:update_request) do
      patch "/api/v1/demandes/#{authorization_request.id}", params:, headers: auth_headers
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:params) do
      { demande: { data: { intitule: 'Projet mis à jour' } } }
    end

    it 'updates the authorization request' do
      update_request

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']['intitule']).to eq('Projet mis à jour')
    end

    context 'without any authorization header' do
      let(:auth_headers) { {} }

      it 'returns 401' do
        update_request

        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'creates an update_by_api event' do
      update_request

      event = authorization_request.events_without_bulk_update.find_by(name: 'update_by_api')

      expect(event).to be_present
    end

    context 'when authorization request is validated' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it 'returns 422' do
        update_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors'].first['title']).to eq('État non modifiable')
      end
    end

    context 'when authorization request is refused' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :refused) }

      it 'returns 422' do
        update_request

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when authorization request is in submitted state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it 'allows the update' do
        update_request

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid data keys' do
      let(:params) do
        { demande: { data: { unknown_key: 'value' } } }
      end

      it 'returns 422 with source pointer' do
        update_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors'].first['source']['pointer']).to eq('/data/unknown_key')
      end
    end

    context 'when enabling france_connect modality on an api-particulier form' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }
      let(:authorization_request) do
        create(:authorization_request, :api_particulier, form_uid: 'api-particulier-aiga')
      end
      let(:params) do
        { demande: { data: { modalities: %w[france_connect] } } }
      end

      it 'applies FranceConnect defaults via AssignFranceConnectDefaults' do
        update_request

        expect(authorization_request.reload.fc_eidas).to eq(FranceConnectDefaultData::FC_EIDAS)
      end
    end
  end
end
