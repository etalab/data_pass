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

        validate_request_and_response!
      end
    end

    context 'when user has no developer roles' do
      let(:user) { create(:user) }

      it 'responds with not found' do
        get_index

        expect(response).to have_http_status(:not_found)

        validate_request_and_response!
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

          validate_request_and_response!
        end

        it 'returns correct authorization_request_class for forms' do
          get_index

          forms = response.parsed_body
          forms.each do |form|
            expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIEntreprise')
          end
        end
      end

      context 'when requesting forms for a definition the user does not have access to' do
        let(:definition_id) { 'api_particulier' }

        it 'responds with not found' do
          get_index

          expect(response).to have_http_status(:not_found)
          validate_request_and_response!
        end
      end

      context 'when requesting forms for a non-existent definition' do
        let(:definition_id) { 'non_existent' }

        it 'responds with not found' do
          get_index

          expect(response).to have_http_status(:not_found)

          validate_request_and_response!
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

        api_entreprise_form_uids = AuthorizationDefinition.find('api_entreprise').available_forms.pluck(:uid)

        forms = response.parsed_body
        forms.each do |form|
          expect(form['authorization_request_class']).to eq('AuthorizationRequest::APIParticulier')
          expect(api_entreprise_form_uids).not_to include(form['uid'])
        end
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
        validate_request_and_response!
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
        validate_request_and_response!
      end
    end
  end
end
