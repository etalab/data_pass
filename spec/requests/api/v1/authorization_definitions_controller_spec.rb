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
          'name_with_stage',
          'multi_stage?',
          'authorization_request_class',
          'data',
          'scopes'
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

      it 'returns correct data attribute with extra_attributes and scopes' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['data']).to be_a(Array)
        expect(definition['scopes']).to be_a(Array)

        extra_attributes = AuthorizationRequest::APIEntreprise.extra_attributes
        extra_attributes.each do |attr|
          expect(definition['data']).to include(attr.to_s)
        end

        expect(definition['data']).to include('scopes')
      end

      it 'returns scopes as array of scope values' do
        get_index

        definition = response.parsed_body[0]
        scopes = definition['scopes']
        expect(scopes).to be_a(Array)
        # Verify scopes contain expected API Entreprise scope values from config
        expect(scopes).to include('unites_legales_etablissements_insee', 'open_data_unites_legales_etablissements_insee', 'open_data_extrait_rcs_infogreffe')
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

      it 'returns correct data attribute with extra_attributes and scopes' do
        get_index

        definition = response.parsed_body[0]
        expect(definition['data']).to be_a(Array)
        expect(definition['scopes']).to be_a(Array)

        extra_attributes = AuthorizationRequest::APIParticulier.extra_attributes
        extra_attributes.each do |attr|
          expect(definition['data']).to include(attr.to_s)
        end

        expect(definition['data']).to include('scopes')
      end

      it 'returns scopes as array of scope values for API Particulier' do
        get_index

        definition = response.parsed_body[0]
        scopes = definition['scopes']
        expect(scopes).to be_a(Array)
        # Verify scopes contain expected API Particulier scope values from config
        expect(scopes).to include('cnaf_quotient_familial', 'cnaf_allocataires', 'pole_emploi_identifiant')
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

      it 'returns correct name_with_stage for sandbox definition' do
        get_index

        sandbox_definition = response.parsed_body.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        expect(sandbox_definition['name_with_stage']).to eq('API Impôt Particulier (Bac à sable)')
      end

      it 'returns correct name_with_stage for production definition' do
        get_index

        production_definition = response.parsed_body.find { |d| d['id'] == 'api_impot_particulier' }
        expect(production_definition['name_with_stage']).to eq('API Impôt Particulier (Production)')
      end

      it 'returns correct multi_stage values for both definitions' do
        get_index

        definitions = response.parsed_body
        sandbox_def = definitions.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        production_def = definitions.find { |d| d['id'] == 'api_impot_particulier' }

        expect(sandbox_def['multi_stage?']).to be(true)
        expect(production_def['multi_stage?']).to be(true)
      end

      it 'returns correct authorization_request_classes for each definition' do
        get_index

        definitions = response.parsed_body
        sandbox_def = definitions.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        production_def = definitions.find { |d| d['id'] == 'api_impot_particulier' }

        expect(sandbox_def['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
        expect(production_def['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulier')
      end

      it 'returns correct data attribute for both sandbox and production definitions' do
        get_index

        definitions = response.parsed_body
        sandbox_def = definitions.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        production_def = definitions.find { |d| d['id'] == 'api_impot_particulier' }

        [sandbox_def, production_def].each do |definition|
          expect(definition['data']).to be_a(Array)
          expect(definition['scopes']).to be_a(Array)
        end

        # Verify sandbox definition contains extra_attributes from sandbox class
        extra_attributes_sandbox = AuthorizationRequest::APIImpotParticulierSandbox.extra_attributes
        extra_attributes_sandbox.each do |attr|
          expect(sandbox_def['data']).to include(attr.to_s)
        end

        # Verify production definition contains extra_attributes from production class
        extra_attributes_production = AuthorizationRequest::APIImpotParticulier.extra_attributes
        extra_attributes_production.each do |attr|
          expect(production_def['data']).to include(attr.to_s)
        end
      end

      it 'returns correct scopes for both sandbox and production definitions' do
        get_index

        definitions = response.parsed_body
        sandbox_def = definitions.find { |d| d['id'] == 'api_impot_particulier_sandbox' }
        production_def = definitions.find { |d| d['id'] == 'api_impot_particulier' }

        # Both should have the same scopes as they reference the same scopes config
        expected_scopes = %w[dgfip_annee_n_moins_1 dgfip_rfr dgfip_sitfam dgfip_nbpart dgfip_pac]

        expect(sandbox_def['scopes']).to include(*expected_scopes)
        expect(production_def['scopes']).to include(*expected_scopes)
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

  describe 'GET /api/v1/definitions/:id' do
    subject(:get_show) do
      get "/api/v1/definitions/#{definition_id}", headers: { 'Authorization' => "Bearer #{access_token.token}" }
    end

    let(:definition_id) { 'api_entreprise' }

    context 'when user is not authenticated' do
      it 'responds with unauthorized' do
        get "/api/v1/definitions/#{definition_id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user has no developer roles' do
      let(:user) { create(:user) }

      it 'responds with not found' do
        get_show

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user has developer role for api_entreprise' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

      context 'when requesting api_entreprise definition' do
        let(:definition_id) { 'api_entreprise' }

        it 'responds OK with the definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_entreprise')
          expect(response.parsed_body['name']).to eq('API Entreprise')
        end

        it 'includes all expected attributes in the response' do
          get_show

          definition = response.parsed_body
          expect(definition).to include(
            'id',
            'name',
            'name_with_stage',
            'multi_stage?',
            'authorization_request_class',
            'data',
            'scopes'
          )
        end

        it 'returns correct authorization_request_class' do
          get_show

          definition = response.parsed_body
          expect(definition['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
        end

        it 'returns correct name_with_stage' do
          get_show

          definition = response.parsed_body
          expect(definition['name_with_stage']).to eq('API Entreprise')
        end

        it 'returns correct multi_stage value' do
          get_show

          definition = response.parsed_body
          expect(definition['multi_stage?']).to be(false)
        end

        it 'returns correct data attribute with extra_attributes and scopes' do
          get_show

          definition = response.parsed_body
          expect(definition['data']).to be_a(Array)
          expect(definition['scopes']).to be_a(Array)

          extra_attributes = AuthorizationRequest::APIEntreprise.extra_attributes
          extra_attributes.each do |attr|
            expect(definition['data']).to include(attr.to_s)
          end

          expect(definition['data']).to include('scopes')
        end

        it 'returns scopes as array of scope values' do
          get_show

          definition = response.parsed_body
          scopes = definition['scopes']
          expect(scopes).to be_a(Array)
          expect(scopes).to include('unites_legales_etablissements_insee', 'open_data_unites_legales_etablissements_insee', 'open_data_extrait_rcs_infogreffe')
        end
      end

      context 'when requesting a definition the user does not have access to' do
        let(:definition_id) { 'api_particulier' }

        it 'responds with not found' do
          get_show

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when requesting a non-existent definition' do
        let(:definition_id) { 'non_existent' }

        it 'responds with not found' do
          get_show

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user has developer role for api_impot_particulier (multi-stage)' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_impot_particulier api_impot_particulier_sandbox]) }

      context 'when requesting sandbox definition' do
        let(:definition_id) { 'api_impot_particulier_sandbox' }

        it 'responds OK with the sandbox definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_impot_particulier_sandbox')
          expect(response.parsed_body['name']).to eq('API Impôt Particulier')
        end

        it 'returns correct name_with_stage for sandbox' do
          get_show

          definition = response.parsed_body
          expect(definition['name_with_stage']).to eq('API Impôt Particulier (Bac à sable)')
        end

        it 'returns correct multi_stage value for sandbox' do
          get_show

          definition = response.parsed_body
          expect(definition['multi_stage?']).to be(true)
        end

        it 'returns correct authorization_request_class for sandbox' do
          get_show

          definition = response.parsed_body
          expect(definition['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
        end

        it 'returns correct data attribute for sandbox definition' do
          get_show

          definition = response.parsed_body
          expect(definition['data']).to be_a(Array)
          expect(definition['scopes']).to be_a(Array)

          extra_attributes = AuthorizationRequest::APIImpotParticulierSandbox.extra_attributes
          extra_attributes.each do |attr|
            expect(definition['data']).to include(attr.to_s)
          end

          expect(definition['data']).to include('scopes')
        end
      end

      context 'when requesting production definition' do
        let(:definition_id) { 'api_impot_particulier' }

        it 'responds OK with the production definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_impot_particulier')
          expect(response.parsed_body['name']).to eq('API Impôt Particulier')
        end

        it 'returns correct name_with_stage for production' do
          get_show

          definition = response.parsed_body
          expect(definition['name_with_stage']).to eq('API Impôt Particulier (Production)')
        end

        it 'returns correct multi_stage value for production' do
          get_show

          definition = response.parsed_body
          expect(definition['multi_stage?']).to be(true)
        end

        it 'returns correct authorization_request_class for production' do
          get_show

          definition = response.parsed_body
          expect(definition['authorization_request_class']).to eq('AuthorizationRequest::APIImpotParticulier')
        end

        it 'returns correct data attribute for production definition' do
          get_show

          definition = response.parsed_body
          expect(definition['data']).to be_a(Array)
          expect(definition['scopes']).to be_a(Array)

          extra_attributes = AuthorizationRequest::APIImpotParticulier.extra_attributes
          extra_attributes.each do |attr|
            expect(definition['data']).to include(attr.to_s)
          end

          expect(definition['data']).to include('scopes')
        end
      end
    end

    context 'when user has multiple developer roles' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_particulier]) }

      context 'when requesting api_entreprise definition' do
        let(:definition_id) { 'api_entreprise' }

        it 'responds OK with api_entreprise definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_entreprise')
        end
      end

      context 'when requesting api_particulier definition' do
        let(:definition_id) { 'api_particulier' }

        it 'responds OK with api_particulier definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_particulier')
        end
      end
    end
  end
end
