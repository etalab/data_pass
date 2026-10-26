RSpec.describe 'API: Authorization request submission' do
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:) }
  let(:token_scopes) { 'public read_authorizations submit_authorizations' }
  let(:token) { create(:access_token, application:, scopes: token_scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let!(:grant) { create(:api_access_grant, oauth_application: application) }
  let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }
  let(:params) do
    {
      consentement: {
        terms_of_service_accepted: true,
        data_protection_officer_informed: true
      }
    }
  end

  before(:all) do
    Bullet.enable = false
  end

  after(:all) do
    Bullet.enable = true
  end

  def errors
    response.parsed_body['errors']
  end

  describe 'POST /api/v1/demandes/:id/soumettre' do
    subject(:submit_request) do
      post "/api/v1/demandes/#{authorization_request.id}/soumettre", params:, headers:, as: :json
    end

    context 'with a complete draft and every consent given' do
      it 'submits the request and returns it up to date' do
        submit_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['state']).to eq('submitted')
        expect(authorization_request.reload.state).to eq('submitted')
      end

      it 'matches the OpenAPI contract' do
        submit_request

        expect(response).to have_http_status(:ok)
        validate_request_and_response!
      end

      it 'keeps the applicant as the person who submitted' do
        submit_request

        expect(authorization_request.events.where(name: 'submit').last.user).to eq(authorization_request.applicant)
      end

      it 'records which application submitted the request' do
        submit_request

        expect(authorization_request.events.where(name: 'submit').last.api_application_name).to eq(application.name)
      end

      it_behaves_like 'delivers a webhook', event_name: :submit do
        subject { submit_request }
      end
    end

    context 'when the request needs changes' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested, fill_all_attributes: true) }

      it 'submits it again' do
        submit_request

        expect(response).to have_http_status(:ok)
        expect(authorization_request.reload.state).to eq('submitted')
      end
    end

    context 'when the data protection officer is not filled in' do
      before do
        authorization_request.update!(data: authorization_request.data.merge('delegue_protection_donnees_family_name' => ''))
      end

      it 'answers 422 and points at the field' do
        submit_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(errors).to include(
          a_hash_including(
            'status' => '422',
            'title' => 'Demande invalide',
            'source' => { 'pointer' => '/data/delegue_protection_donnees_family_name' }
          )
        )
      end

      it 'leaves the request as a draft' do
        expect { submit_request }.not_to change { authorization_request.reload.state }.from('draft')
      end

      it 'matches the OpenAPI contract' do
        submit_request

        expect(response).to have_http_status(:unprocessable_content)
        validate_response!
      end
    end

    context 'when a consent is missing' do
      let(:params) { { consentement: { terms_of_service_accepted: true } } }

      it 'answers 422 and points at the missing consent' do
        submit_request

        expect(response).to have_http_status(:unprocessable_content)
        expect(errors).to eq(
          [
            {
              'status' => '422',
              'title' => 'Consentement manquant',
              'detail' => 'La case « data_protection_officer_informed » doit être cochée pour soumettre cette demande.',
              'source' => { 'pointer' => '/consentement/data_protection_officer_informed' }
            }
          ]
        )
      end

      it 'leaves the request as a draft' do
        expect { submit_request }.not_to change { authorization_request.reload.state }.from('draft')
      end
    end

    context 'when the consentement object is absent' do
      let(:params) { {} }

      it 'answers 400' do
        submit_request

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the consentement is not an object' do
      let(:params) { { consentement: 'oui' } }

      it 'answers 400' do
        submit_request

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the consentement holds keys which are not consents' do
      let(:params) do
        { consentement: { terms_of_service_accepted: true, data_protection_officer_informed: true, state: 'validated' } }
      end

      it 'submits the request and ignores them' do
        submit_request

        expect(response).to have_http_status(:ok)
        expect(authorization_request.reload.state).to eq('submitted')
      end
    end

    context 'when the request is already under instruction' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it 'answers 422 and does not change the state' do
        expect { submit_request }.not_to change { authorization_request.reload.state }

        expect(response).to have_http_status(:unprocessable_content)
        expect(errors.first).to include('title' => 'État non modifiable')
      end
    end

    context 'when the request is already validated' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it 'answers 422 and does not change the state' do
        expect { submit_request }.not_to change { authorization_request.reload.state }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'when the application only has write_authorizations' do
      let(:token_scopes) { 'public write_authorizations' }

      it 'answers 403 and changes nothing' do
        expect { submit_request }.not_to change { authorization_request.reload.state }

        expect(response).to have_http_status(:forbidden)
        expect(errors.first).to include('title' => 'Droit API manquant')
      end
    end

    context 'when the token carries the scope but the submission right was revoked' do
      let!(:grant) { create(:api_access_grant, :revoked, oauth_application: application) }

      it 'answers 403 with the explicit message and changes nothing' do
        expect { submit_request }.not_to change { authorization_request.reload.state }

        expect(response).to have_http_status(:forbidden)
        expect(errors.first['detail']).to include('soumettre')
      end
    end

    context 'when the right only covers validation' do
      let!(:grant) { create(:api_access_grant, :validation, oauth_application: application) }

      it 'answers 403' do
        submit_request

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the request belongs to a type the developer cannot access' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, :draft) }

      it 'answers 404' do
        submit_request

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without a token' do
      let(:headers) { {} }

      it 'answers 401' do
        submit_request

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
