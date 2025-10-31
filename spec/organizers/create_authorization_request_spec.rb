RSpec.describe CreateAuthorizationRequest, type: :organizer do
  describe '.call' do
    subject(:create_authorization_request) do
      described_class.call(
        authorization_request_form:,
        user:,
        authorization_request_params:,
      )
    end

    let(:user) { create(:user) }

    context 'with basic form' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          contact_metier_family_name: 'Dupont',
        )
      end

      it { is_expected.to be_success }

      it 'creates an authorization request linked to user, organization, form and valid params' do
        expect { create_authorization_request }.to change(AuthorizationRequest, :count).by(1)

        authorization_request = AuthorizationRequest.last

        expect(authorization_request.applicant).to eq(user)
        expect(authorization_request.organization).to eq(user.current_organization)
        expect(authorization_request.form_uid).to eq(authorization_request_form.id)

        expect(authorization_request.contact_metier_family_name).to eq('Dupont')
      end

      it_behaves_like 'creates an event', event_name: :create

      context 'when authorization request has webhooks activated for all events' do
        let(:authorization_request_kind) { :api_entreprise }
        let!(:webhook) do
          create(:webhook,
            authorization_definition_id: 'api_entreprise',
            events: ['create'],
            validated: true,
            enabled: true)
        end

        it 'delivers a webhook for this event' do
          expect { subject }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
            webhook.id,
            instance_of(Integer),
            'create',
            a_string_including('"event":"create"')
          ), 'Expected to have enqueued a webhook delivery job with the event name create'
        end
      end
    end

    context 'with a form which has default scopes on definition' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          responsable_traitement_family_name: 'New Dupont',
        )
      end

      it { is_expected.to be_success }

      it 'creates an authorization request with scopes' do
        create_authorization_request

        authorization_request = AuthorizationRequest.last

        expect(authorization_request.scopes).to be_present
        expect(authorization_request.scopes).to include('open_data_unites_legales_etablissements_insee')
        expect(authorization_request.responsable_traitement_family_name).to eq('New Dupont')
      end
    end

    context 'with a form which has default scopes on both definition and form' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise-marches-publics') }
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          responsable_traitement_family_name: 'New Dupont',
        )
      end

      it { is_expected.to be_success }

      it 'creates an authorization request with scopes' do
        create_authorization_request

        authorization_request = AuthorizationRequest.last

        expect(authorization_request.scopes).to be_present
        expect(authorization_request.scopes).to include('open_data_unites_legales_etablissements_insee')
        expect(authorization_request.scopes).to include('unites_legales_etablissements_insee')
        expect(authorization_request.responsable_traitement_family_name).to eq('New Dupont')
      end
    end

    context 'with a form which has data key' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise-mgdis') }
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          responsable_traitement_family_name: 'New Dupont',
        )
      end

      it { is_expected.to be_success }

      it 'creates an authorization request with data from the data key' do
        expect { create_authorization_request }.to change(AuthorizationRequest, :count).by(1)

        authorization_request = AuthorizationRequest.last

        expect(authorization_request.responsable_traitement_family_name).to eq('New Dupont')
        expect(authorization_request.contact_technique_email).to eq('contact-mgdis@yopmail.com')
      end
    end

    context 'with a form which has data key and static blocks' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise-marches-publics') }
      let(:authorization_request_params) do
        ActionController::Parameters.new
      end

      it { is_expected.to be_success }
    end

    describe 'API Particulier authorization request' do
      let(:authorization_request_params) { ActionController::Parameters.new }

      context 'with a form which has modalities on data key' do
        let(:authorization_request_form) { AuthorizationRequestForm.find('api-particulier-3d-ouest') }

        it { is_expected.to be_success }

        it 'creates an authorization request with modalities' do
          expect { create_authorization_request }.to change(AuthorizationRequest, :count).by(1)

          authorization_request = AuthorizationRequest.last

          expect(authorization_request.modalities).to be_present
          expect(authorization_request.modalities).to eq(%w[formulaire_qf params])
        end
      end

      context 'with a form which has no modalities on data key' do
        let(:authorization_request_form) { AuthorizationRequestForm.find('api-particulier') }

        it { is_expected.to be_success }

        it 'creates an authorization request with default modalities' do
          expect { create_authorization_request }.to change(AuthorizationRequest, :count).by(1)

          authorization_request = AuthorizationRequest.last

          expect(authorization_request.modalities).to be_present
          expect(authorization_request.modalities).to eq(%w[params])
        end
      end
    end

    describe 'documents assignation' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }

      let(:authorization_request_params) do
        ActionController::Parameters.new(
          maquette_projet: [Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf')],
          cadre_juridique_document: [
            Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf'),
            Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf'),
          ]
        )
      end

      it { is_expected.to be_a_success }

      it 'works for single and multiple documents' do
        create_authorization_request

        last_authorization_request = AuthorizationRequest.last

        expect(last_authorization_request.maquette_projet.blobs.count).to eq(1)
        expect(last_authorization_request.cadre_juridique_document.blobs.count).to eq(2)
      end
    end
  end
end
