RSpec.describe 'API: Authorization request forms' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:) }

  describe 'GET /api/v1/definitions/:id/formulaires' do
    subject(:get_index) do
      get "/api/v1/definitions/#{definition_id}/formulaires", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    let(:definition_id) { 'api_entreprise' }

    context 'when user is not authenticated' do
      it 'responds with unauthorized' do
        get "/api/v1/definitions/#{definition_id}/formulaires"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user has no developer roles' do
      let(:user) { create(:user) }

      it 'responds with not found' do
        get_index

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user has developer role for api_entreprise' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

      context 'when requesting forms for api_entreprise definition' do
        let(:definition_id) { 'api_entreprise' }

        it 'responds OK with the forms' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to be_an(Array)
          expect(response.parsed_body.count).to be > 0
        end

        it 'includes all expected attributes in each form' do
          get_index

          form = response.parsed_body.first
          expect(form).to include(
            'uid',
            'name',
            'description',
            'use_case',
            'authorization_request_class',
            'data'
          )
        end

        it 'returns correct authorization_request_class for forms' do
          get_index

          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
          end
        end

        it 'returns data for prefilled forms' do
          get_index

          form = response.parsed_body.find { |f| f['uid'] == 'api-entreprise-marches-publics' }
          expect(form['data']).to be_present
          expect(form['data']).to be_a(Hash)
          expect(form['data']).to include(
            'cadre_juridique_nature',
            'cadre_juridique_url',
            'scopes'
          )
        end

        it 'returns forms with unique UIDs' do
          get_index

          forms = response.parsed_body
          uids = forms.map { |form| form['uid'] }
          expect(uids).to eq(uids.uniq)
        end
      end

      context 'when requesting forms for a definition the user does not have access to' do
        let(:definition_id) { 'api_particulier' }

        it 'responds with not found' do
          get_index

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when requesting forms for a non-existent definition' do
        let(:definition_id) { 'non_existent' }

        it 'responds with not found' do
          get_index

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user has developer role for api_particulier' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }
      let(:definition_id) { 'api_particulier' }

      it 'responds OK with api_particulier forms' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_an(Array)
        expect(response.parsed_body.count).to be > 0

        forms = response.parsed_body
        forms.each do |form|
          expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIParticulier')
        end
      end

      it 'returns different forms than api_entreprise' do
        # Get api_particulier forms
        get_index
        api_particulier_forms = response.parsed_body

        # Create a new user with api_entreprise access and get those forms
        api_entreprise_user = create(:user, :developer, authorization_request_types: %w[api_entreprise])
        api_entreprise_application = create(:oauth_application, owner: api_entreprise_user)
        api_entreprise_access_token = create(:access_token, application: api_entreprise_application)

        get '/api/v1/definitions/api_entreprise/formulaires', headers: { 'Authorization' => "Bearer #{api_entreprise_access_token.token}" }
        api_entreprise_forms = response.parsed_body

        # Forms should be different
        api_particulier_uids = api_particulier_forms.map { |f| f['uid'] }.sort
        api_entreprise_uids = api_entreprise_forms.map { |f| f['uid'] }.sort

        expect(api_particulier_uids).not_to eq(api_entreprise_uids)
      end
    end

    context 'when user has developer role for api_impot_particulier (multi-stage)' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_impot_particulier api_impot_particulier_sandbox]) }

      context 'when requesting forms for sandbox definition' do
        let(:definition_id) { 'api_impot_particulier_sandbox' }

        it 'responds OK with sandbox forms' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to be_an(Array)
          expect(response.parsed_body.count).to be > 0

          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
          end
        end
      end

      context 'when requesting forms for production definition' do
        let(:definition_id) { 'api_impot_particulier' }

        it 'responds OK with production forms' do
          get_index

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to be_an(Array)
          expect(response.parsed_body.count).to be > 0

          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulier')
          end
        end
      end
    end

    context 'when user has multiple developer roles' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_particulier]) }

      context 'when requesting api_entreprise forms' do
        let(:definition_id) { 'api_entreprise' }

        it 'responds OK with api_entreprise forms' do
          get_index

          expect(response).to have_http_status(:ok)
          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
          end
        end
      end

      context 'when requesting api_particulier forms' do
        let(:definition_id) { 'api_particulier' }

        it 'responds OK with api_particulier forms' do
          get_index

          expect(response).to have_http_status(:ok)
          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIParticulier')
          end
        end
      end
    end

    context 'when user has developer role for non-existent authorization type' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[non_existent]) }
      let(:definition_id) { 'api_entreprise' }

      it 'responds with not found' do
        get_index

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user has mixed valid and invalid authorization types' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise non_existent]) }
      let(:definition_id) { 'api_entreprise' }

      it 'responds OK with valid definition forms' do
        get_index

        expect(response).to have_http_status(:ok)
        forms = response.parsed_body
        forms.each do |form|
          expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
        end
      end
    end
  end
end
