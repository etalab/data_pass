RSpec.describe 'API: Authorization definitions' do
  let(:user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: user) }
  let(:access_token) { create(:access_token, application:) }

  shared_examples 'validates definition attributes' do |expected_definition|
    it 'includes all expected attributes in the response' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      expect(definition).to include(
        'id',
        'name',
        'multi_stage?',
        'authorization_request_class',
        'scopes'
      )
    end

    it 'returns correct authorization_request_class' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      expect(definition['authorization_request_class']).to eq(expected_definition[:authorization_request_class])
    end

    it 'returns correct name' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      expect(definition['name']).to eq(expected_definition[:name])
    end

    it 'returns correct multi_stage value' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      expect(definition['multi_stage?']).to be(expected_definition[:multi_stage])
    end

    it 'returns correct attributes with extra_attributes and scopes' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      expect(definition['scopes']).to be_a(Array)
    end

    it 'returns scopes as array of scope objects' do
      subject

      definition = if response.parsed_body.is_a?(Array)
                     response.parsed_body.find { |d| d['id'] == expected_definition[:id] }
                   else
                     response.parsed_body
                   end

      scopes = definition['scopes']
      expect(scopes).to be_a(Array)

      scope_values = scopes.map { |scope| scope['value'] }
      expected_definition[:expected_scope_values].each do |expected_scope|
        expect(scope_values).to include(expected_scope)
      end
    end
  end

  shared_examples 'validates multi-stage definitions' do |sandbox_def, production_def|
    it 'responds OK with both sandbox and production definitions' do
      subject

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.count).to eq(2)

      definition_ids = response.parsed_body.map { |d| d['id'] }
      expect(definition_ids).to contain_exactly(sandbox_def[:id], production_def[:id])
    end

    it 'returns correct names for both definitions' do
      subject

      sandbox_definition = response.parsed_body.find { |d| d['id'] == sandbox_def[:id] }
      production_definition = response.parsed_body.find { |d| d['id'] == production_def[:id] }

      expect(sandbox_definition['name']).to eq(sandbox_def[:name])
      expect(production_definition['name']).to eq(production_def[:name])
    end

    it 'returns correct multi_stage values for both definitions' do
      subject

      definitions = response.parsed_body
      sandbox_def_response = definitions.find { |d| d['id'] == sandbox_def[:id] }
      production_def_response = definitions.find { |d| d['id'] == production_def[:id] }

      expect(sandbox_def_response['multi_stage?']).to be(sandbox_def[:multi_stage])
      expect(production_def_response['multi_stage?']).to be(production_def[:multi_stage])
    end

    it 'returns correct authorization_request_classes for each definition' do
      subject

      definitions = response.parsed_body
      sandbox_def_response = definitions.find { |d| d['id'] == sandbox_def[:id] }
      production_def_response = definitions.find { |d| d['id'] == production_def[:id] }

      expect(sandbox_def_response['authorization_request_class']).to eq(sandbox_def[:authorization_request_class])
      expect(production_def_response['authorization_request_class']).to eq(production_def[:authorization_request_class])
    end

    it 'returns correct attributes for both sandbox and production definitions' do
      subject

      definitions = response.parsed_body
      sandbox_def_response = definitions.find { |d| d['id'] == sandbox_def[:id] }
      production_def_response = definitions.find { |d| d['id'] == production_def[:id] }

      [sandbox_def_response, production_def_response].each do |definition|
        expect(definition['scopes']).to be_a(Array)
      end
    end

    it 'returns correct scopes for both sandbox and production definitions' do
      subject

      definitions = response.parsed_body
      sandbox_def_response = definitions.find { |d| d['id'] == sandbox_def[:id] }
      production_def_response = definitions.find { |d| d['id'] == production_def[:id] }

      sandbox_scope_values = sandbox_def_response['scopes'].map { |scope| scope['value'] }
      production_scope_values = production_def_response['scopes'].map { |scope| scope['value'] }

      sandbox_def[:expected_scope_values].each do |expected_scope|
        expect(sandbox_scope_values).to include(expected_scope)
      end

      production_def[:expected_scope_values].each do |expected_scope|
        expect(production_scope_values).to include(expected_scope)
      end
    end
  end

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

      it_behaves_like 'validates definition attributes', {
        id: 'api_entreprise',
        name: 'API Entreprise',
        multi_stage: false,
        authorization_request_class: 'AuthorizationRequest::APIEntreprise',
        expected_scope_values: %w[unites_legales_etablissements_insee open_data_unites_legales_etablissements_insee open_data_extrait_rcs_infogreffe]
      }

      context 'when definition is multi-stage' do
        let(:user) { create(:user, :developer, authorization_request_types: %w[api_impot_particulier_sandbox]) }

        it 'returns correct name' do
          get_index

          definition = response.parsed_body[0]
          expect(definition['name']).to eq('API Impôt Particulier (Bac à sable)')
        end
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

      it_behaves_like 'validates definition attributes', {
        id: 'api_particulier',
        name: 'API Particulier',
        multi_stage: false,
        authorization_request_class: 'AuthorizationRequest::APIParticulier',
        expected_scope_values: %w[cnaf_quotient_familial cnaf_allocataires pole_emploi_identifiant]
      }
    end

    context 'when user has developer role for api_impot_particulier (multi-stage)' do
      let(:user) { create(:user, :developer, authorization_request_types: %w[api_impot_particulier api_impot_particulier_sandbox]) }

      it_behaves_like 'validates multi-stage definitions',
        {
          id: 'api_impot_particulier_sandbox',
          name: 'API Impôt Particulier (Bac à sable)',
          multi_stage: true,
          authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox',
          expected_scope_values: %w[dgfip_annee_n_moins_1 dgfip_rfr dgfip_sitfam dgfip_nbpart dgfip_pac]
        },
        {
          id: 'api_impot_particulier',
          name: 'API Impôt Particulier (Production)',
          multi_stage: true,
          authorization_request_class: 'AuthorizationRequest::APIImpotParticulier',
          expected_scope_values: %w[dgfip_annee_n_moins_1 dgfip_rfr dgfip_sitfam dgfip_nbpart dgfip_pac]
        }
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

        it_behaves_like 'validates definition attributes', {
          id: 'api_entreprise',
          name: 'API Entreprise',
          multi_stage: false,
          authorization_request_class: 'AuthorizationRequest::APIEntreprise',
          expected_scope_values: %w[unites_legales_etablissements_insee open_data_unites_legales_etablissements_insee open_data_extrait_rcs_infogreffe]
        }
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
          expect(response.parsed_body['name']).to eq('API Impôt Particulier (Bac à sable)')
        end

        it_behaves_like 'validates definition attributes', {
          id: 'api_impot_particulier_sandbox',
          name: 'API Impôt Particulier (Bac à sable)',
          multi_stage: true,
          authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox',
          expected_scope_values: %w[dgfip_annee_n_moins_1 dgfip_rfr dgfip_sitfam dgfip_nbpart dgfip_pac]
        }
      end

      context 'when requesting production definition' do
        let(:definition_id) { 'api_impot_particulier' }

        it 'responds OK with the production definition' do
          get_show

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['id']).to eq('api_impot_particulier')
          expect(response.parsed_body['name']).to eq('API Impôt Particulier (Production)')
        end

        it_behaves_like 'validates definition attributes', {
          id: 'api_impot_particulier',
          name: 'API Impôt Particulier (Production)',
          multi_stage: true,
          authorization_request_class: 'AuthorizationRequest::APIImpotParticulier',
          expected_scope_values: %w[dgfip_annee_n_moins_1 dgfip_rfr dgfip_sitfam dgfip_nbpart dgfip_pac]
        }
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
