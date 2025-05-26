RSpec.describe 'API: Authorization definitions' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:) }

  describe 'GET /api/v1/definitions' do
    subject(:get_index) do
      get '/api/v1/definitions', headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    context 'when user is not authenticated' do
      it 'responds with unauthorized' do
        get '/api/v1/definitions'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user has no developer roles' do
      let(:user) { create(:user) }

      it 'responds with an empty array' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context 'when user has developer role for api_entreprise' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

      it 'responds OK with api_entreprise definition only' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq('api_entreprise')
        expect(response.parsed_body[0]['name']).to eq('API Entreprise')
      end

      it 'includes all expected attributes in the response' do
        get_index

        definition = response.parsed_body[0]
        expect(definition).to include(
          'id',
          'name',
          'provider',
          'description',
          'link',
          'access_link',
          'cgu_link',
          'support_email',
          'kind',
          'scopes',
          'blocks',
          'features',
          'stage',
          'name_with_stage',
          'multi_stage?',
          'authorization_request_class'
        )
      end

      it 'returns correct authorization_request_class' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
      end

      it 'returns correct name_with_stage' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['name_with_stage']).to eq('API Entreprise')
      end

      it 'returns correct multi_stage value' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['multi_stage?']).to be(false)
      end

      it 'includes scopes array' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['scopes']).to be_an(Array)
        expect(definition['scopes']).not_to be_empty
      end

      it 'includes blocks array' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['blocks']).to be_an(Array)
        expect(definition['blocks']).not_to be_empty
      end
    end

    context 'when user has developer role for api_particulier' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }

      it 'responds OK with api_particulier definition only' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq('api_particulier')
        expect(response.parsed_body[0]['name']).to eq('API Particulier')
      end

      it 'returns correct authorization_request_class' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['authorization_request_class']).to eq('AuthorizationRequest::APIParticulier')
      end
    end

    context 'when user has developer role for api_impot_particulier (multi-stage)' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_impot_particulier api_impot_particulier_sandbox]) }

      it 'responds OK with both sandbox and production definitions' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(2)

        definition_ids = response.parsed_body.map { |d| d['id'] }
        expect(definition_ids).to contain_exactly('api_impot_particulier', 'api_impot_particulier_sandbox')
      end

      it 'returns correct stage information for sandbox definition' do
        get_index

        sandbox_definition = response.parsed_body.find { |d| d['id'] == 'api_impot_particulier_sandbox' }

        expect(sandbox_definition['multi_stage?']).to be(true)
        expect(sandbox_definition['name_with_stage']).to eq('API Impôt Particulier (Bac à sable)')
        expect(sandbox_definition['stage']).to include(
          'type' => 'sandbox',
          'next' => include(
            'id' => 'api_impot_particulier',
            'form_id' => 'api-impot-particulier-production'
          )
        )
      end

      it 'returns correct stage information for production definition' do
        get_index

        production_definition = response.parsed_body.find { |d| d['id'] == 'api_impot_particulier' }

        expect(production_definition['multi_stage?']).to be(true)
        expect(production_definition['name_with_stage']).to eq('API Impôt Particulier (Production)')
        expect(production_definition['stage']).to include(
          'type' => 'production',
          'previouses' => include(
            include(
              'id' => 'api_impot_particulier_sandbox',
              'form_id' => 'api-impot-particulier-sandbox'
            )
          )
        )
      end

      it 'returns correct authorization_request_classes for each definition' do
        get_index

        definitions = response.parsed_body
        sandbox_def = definitions.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        production_def = definitions.find { |d| d['id'] == 'api_impot_particulier' }

        expect(sandbox_def['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
        expect(production_def['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulier')
      end

      it 'includes stage-specific attributes in both definitions' do
        get_index

        definitions = response.parsed_body

        definitions.each do |definition|
          expect(definition['stage']).to be_present
          expect(definition['stage']['type']).to be_in(%w[sandbox production])
          expect(definition['multi_stage?']).to be(true)
          expect(definition['name_with_stage']).to include('API Impôt Particulier')
        end
      end
    end

    context 'when user has multiple developer roles' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_particulier]) }

      it 'responds OK with multiple definitions' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(2)

        definition_ids = response.parsed_body.map { |d| d['id'] }
        expect(definition_ids).to contain_exactly('api_entreprise', 'api_particulier')
      end

      it 'returns correct authorization_request_classes for each definition' do
        get_index

        definitions = response.parsed_body
        api_entreprise_def = definitions.find { |d| d['id'] == 'api_entreprise' }
        api_particulier_def = definitions.find { |d| d['id'] == 'api_particulier' }

        expect(api_entreprise_def['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
        expect(api_particulier_def['authorization_request_class']).to eq('AuthorizationRequest::APIParticulier')
      end
    end

    context 'when user has developer role for non-existent authorization type' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[non_existent]) }

      it 'responds with an empty array' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context 'when user has mixed valid and invalid authorization types' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise non_existent]) }

      it 'responds OK with only valid definitions' do
        get_index

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.count).to eq(1)
        expect(response.parsed_body[0]['id']).to eq('api_entreprise')
      end
    end
  end
end
