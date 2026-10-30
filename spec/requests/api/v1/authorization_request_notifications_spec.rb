RSpec.describe 'API: disabling DataPass notifications' do
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:) }
  let(:token_scopes) { 'public submit_authorizations validate_authorizations' }
  let(:token) { create(:access_token, application:, scopes: token_scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:data_provider) do
    slug = AuthorizationDefinition.find('api_entreprise').provider_slug
    DataProvider.find_by(slug:) || create(:data_provider, slug:)
  end
  let(:optional_notifications) { %w[applicant_submit_receipt instructors_new_request gdpr_contacts_approval] }
  let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

  before do
    Bullet.enable = false
    data_provider.update!(api_contract_options: { 'optional_notifications' => optional_notifications })
    create(:api_access_grant, oauth_application: application, data_provider:)
    create(:api_access_grant, :validation, oauth_application: application, data_provider:)
  end

  after { Bullet.enable = true }

  describe 'POST /api/v1/demandes/:id/soumettre' do
    subject(:submit_request) do
      post "/api/v1/demandes/#{authorization_request.id}/soumettre", params:, headers:, as: :json
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }
    let(:consentement) { { terms_of_service_accepted: true, data_protection_officer_informed: true } }
    let(:params) { { consentement:, notifications: false } }

    before { create(:authorization_request_event, :create_by_api, authorization_request:) }

    context 'when the contract makes the emails optional' do
      it 'sends no email to the applicant nor to the instructors' do
        expect { submit_request }.not_to have_enqueued_mail
      end

      it 'submits the request without warning' do
        submit_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to have_key('meta')
      end

      it 'records in the history that notifications were disabled' do
        submit_request

        expect(authorization_request.events.find_by(name: 'submit')).to be_notifications_disabled
      end

      it_behaves_like 'delivers a webhook', event_name: :submit do
        subject { submit_request }
      end

      context 'with a webhook' do
        let!(:webhook) do
          create(:webhook, authorization_definition_id: authorization_request.definition.id, events: %w[submit], validated: true, enabled: true)
        end

        it 'tells the webhook that notifications were disabled' do
          submit_request

          expect(DeliverAuthorizationRequestWebhookJob).to have_been_enqueued.with(
            webhook.id, authorization_request.id, 'submit', hash_including(notifications: false)
          )
        end
      end
    end

    context 'when the contract makes the emails mandatory' do
      let(:optional_notifications) { [] }

      it 'still sends the emails' do
        expect { submit_request }.to have_enqueued_mail(AuthorizationRequestMailer, :submit)
          .and have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit).at_least(:once)
      end

      it 'warns that the parameter was ignored' do
        submit_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.dig('meta', 'warnings', 0, 'title')).to eq('Notifications obligatoires')
      end

      it 'does not flag the history' do
        submit_request

        expect(authorization_request.events.find_by(name: 'submit')).not_to be_notifications_disabled
      end
    end

    context 'when the contract makes only the applicant email optional' do
      let(:optional_notifications) { %w[applicant_submit_receipt] }

      it 'keeps the instructors email only' do
        expect { submit_request }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit).at_least(:once)
        mailer_names = ActiveJob::Base.queue_adapter.enqueued_jobs.filter_map { |job| job[:args]&.first }
        expect(mailer_names).not_to include('AuthorizationRequestMailer')
      end

      it 'warns about the mandatory email' do
        submit_request

        expect(response.parsed_body.dig('meta', 'warnings', 0, 'detail')).to include('instructors_new_request')
      end
    end

    context 'without the notifications parameter' do
      let(:params) { { consentement: } }

      it 'sends every email and does not warn' do
        expect { submit_request }.to have_enqueued_mail(AuthorizationRequestMailer, :submit)
          .and have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit).at_least(:once)
        expect(response.parsed_body).not_to have_key('meta')
      end

      it 'tells the webhook that notifications were sent' do
        webhook = create(:webhook, authorization_definition_id: authorization_request.definition.id, events: %w[submit], validated: true, enabled: true)

        submit_request

        expect(DeliverAuthorizationRequestWebhookJob).to have_been_enqueued.with(
          webhook.id, authorization_request.id, 'submit', hash_including(notifications: true)
        )
      end
    end
  end

  describe 'a notifications value which is not a boolean' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

    it 'is rejected instead of being read as true' do
      post "/api/v1/demandes/#{authorization_request.id}/soumettre",
        params: { consentement: { terms_of_service_accepted: true, data_protection_officer_informed: true }, notifications: 'flase' },
        headers:, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors'].first['title']).to eq('Paramètre invalide')
      expect(authorization_request.reload.state).to eq('draft')
    end
  end

  describe 'POST /api/v1/demandes/:id/valider' do
    subject(:validate_request) do
      post "/api/v1/demandes/#{authorization_request.id}/valider", params:, headers:, as: :json
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }
    let(:params) { { instructeur: { email: instructor.email }, message: 'Conforme', notifications: false } }

    context 'when the contract makes the GDPR emails optional' do
      it 'does not email the GDPR contacts' do
        expect { validate_request }.not_to have_enqueued_mail(GDPRContactMailer)
      end

      it 'does not warn about emails this request never sends' do
        validate_request

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to have_key('meta')
      end

      it 'records in the history that notifications were disabled' do
        validate_request

        expect(authorization_request.events.find_by(name: 'approve')).to be_notifications_disabled
      end
    end

    context 'when the optional emails are not the ones this request sends' do
      let(:optional_notifications) { %w[dgfip_approval] }

      it 'does not flag the history' do
        validate_request

        expect(authorization_request.events.find_by(name: 'approve')).not_to be_notifications_disabled
      end

      it 'still emails the GDPR contacts and warns about it' do
        expect { validate_request }.to have_enqueued_mail(GDPRContactMailer, :delegue_protection_donnees)
        expect(response.parsed_body.dig('meta', 'warnings', 0, 'detail')).to include('gdpr_contacts_approval')
      end
    end

    context 'when the contract makes the GDPR emails mandatory' do
      let(:optional_notifications) { [] }

      it 'emails the GDPR contacts' do
        expect { validate_request }.to have_enqueued_mail(GDPRContactMailer, :delegue_protection_donnees)
      end
    end
  end

  describe 'POST /api/v1/demandes/:id/valider when only the linked FranceConnect email is skipped' do
    subject(:validate_request) do
      post "/api/v1/demandes/#{authorization_request.id}/valider", params:, headers:, as: :json
    end

    let(:owner) { create(:user, :developer, authorization_request_types: %w[api_particulier]) }
    let(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_particulier]) }
    let(:data_provider) do
      slug = AuthorizationDefinition.find('api_particulier').provider_slug
      DataProvider.find_by(slug:) || create(:data_provider, slug:)
    end
    let(:optional_notifications) { %w[linked_france_connect] }
    let(:authorization_request) { create(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields, :submitted, fill_all_attributes: true) }
    let(:params) { { instructeur: { email: instructor.email }, message: 'Conforme', notifications: false } }

    let!(:webhook) do
      create(:webhook, authorization_definition_id: authorization_request.definition.id, events: %w[approve], validated: true, enabled: true)
    end

    around do |example|
      ServiceProvider.find('entrouvert').apipfc_enabled = true
      example.run
    ensure
      ServiceProvider.find('entrouvert').apipfc_enabled = false
    end

    it 'records in the history that notifications were disabled' do
      validate_request

      expect(authorization_request.events.find_by(name: 'approve')).to be_notifications_disabled
    end

    it 'still tells the main webhook that notifications were sent, because its payload is built before the linked email is skipped' do
      validate_request

      expect(DeliverAuthorizationRequestWebhookJob).to have_been_enqueued.with(
        webhook.id, authorization_request.id, 'approve', hash_including(notifications: true)
      )
    end
  end
end
