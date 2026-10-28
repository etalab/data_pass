RSpec.describe 'API: Authorization requests validation' do
  let(:developer) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner: developer, name: 'Éditeur Test') }
  let(:token_scopes) { 'public validate_authorizations' }
  let(:token) { create(:access_token, application:, scopes: token_scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
  let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
  let(:params) { { instructeur: { email: instructor.email }, message: 'Demande conforme' } }
  let(:data_provider) do
    slug = AuthorizationDefinition.find('api_entreprise').provider_slug
    DataProvider.find_by(slug:) || create(:data_provider, slug:)
  end

  describe 'POST /api/v1/demandes/:id/valider' do
    subject(:validate_request) do
      post "/api/v1/demandes/#{authorization_request.id}/valider", params:, headers:, as: :json
    end

    def error
      response.parsed_body['errors'].first
    end

    context 'with a validation grant' do
      before { create(:api_access_grant, :validation, oauth_application: application, data_provider:) }

      it 'validates the request and returns it with its active authorization' do
        validate_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['state']).to eq('validated')
        expect(response.parsed_body['habilitations'].pluck('state')).to eq(%w[active])
      end

      it 'keeps the instructor as author and the application in the history' do
        validate_request

        event = authorization_request.events.find_by(name: 'approve')
        expect(event.user).to eq(instructor)
        expect(event.api_application_name).to eq('Éditeur Test')
      end

      context 'with the update of an existing authorization in instruction' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened_and_submitted) }

        it 'activates the new authorization and obsoletes the previous one' do
          previous_authorization = authorization_request.latest_authorization

          validate_request

          expect(response).to have_http_status(:ok)
          expect(previous_authorization.reload.state).to eq('obsolete')
          expect(authorization_request.reload.latest_authorization.state).to eq('active')
        end
      end

      context 'when the transition fails' do
        before { allow_any_instance_of(AuthorizationRequest).to receive(:approve).and_return(false) } # rubocop:disable RSpec/AnyInstance

        it 'answers with an explicit error and writes nothing' do
          expect { validate_request }.not_to(change(Authorization, :count))

          expect(response).to have_http_status(:unprocessable_content)
          expect(error['title']).to eq('Transition impossible')
        end
      end

      context 'with an instructor email which is not a string' do
        let(:params) { { instructeur: { email: [instructor.email] }, message: 'Demande conforme' } }

        it 'is rejected as an invalid instructor' do
          validate_request

          expect(response).to have_http_status(:unprocessable_content)
          expect(error['title']).to eq('Instructeur invalide')
        end
      end

      context 'without instructor' do
        let(:params) { {} }

        it 'answers 422 and leaves the request untouched' do
          expect { validate_request }.not_to(change { authorization_request.reload.state })

          expect(response).to have_http_status(:unprocessable_content)
          expect(error['title']).to eq('Instructeur invalide')
        end
      end

      context 'with an account which is not instructor on this type' do
        let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }

        it 'answers 422 and leaves the request untouched' do
          expect { validate_request }.not_to(change { authorization_request.reload.state })

          expect(response).to have_http_status(:unprocessable_content)
          expect(error['title']).to eq('Instructeur invalide')
        end
      end

      %i[draft changes_requested refused validated].each do |state|
        context "with a request in #{state} state" do
          let(:authorization_request) { create(:authorization_request, :api_entreprise, state) }

          it 'answers 422 and does not change the state' do
            expect { validate_request }.not_to(change { authorization_request.reload.state })

            expect(response).to have_http_status(:unprocessable_content)
          end
        end
      end
    end

    context 'without validation grant' do
      it 'answers 403 and does not change the state' do
        expect { validate_request }.not_to(change { authorization_request.reload.state })

        expect(response).to have_http_status(:forbidden)
        expect(error['title']).to eq('Droit API manquant')
      end
    end

    context 'with a token which only has write_authorizations' do
      let(:token_scopes) { 'public write_authorizations' }

      before { create(:api_access_grant, :validation, oauth_application: application, data_provider:) }

      it 'answers 403' do
        validate_request

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
