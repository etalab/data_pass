RSpec.describe ApproveAuthorizationRequest do
  include ActiveJob::TestHelper

  describe '.call' do
    subject(:approve_authorization_request) { described_class.call(authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[api_scolarite]) }

    context 'with authorization request in submitted state' do
      let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :submitted) }
      let(:authorization_request_kind) { :api_scolarite }

      it { is_expected.to be_success }

      it 'changes state to validated' do
        expect { approve_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('validated')
      end

      it 'changes last_validated_at' do
        expect { approve_authorization_request }.to change { authorization_request.reload.last_validated_at }
      end

      it 'delivers an email to applicant' do
        expect { approve_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :approve)
      end

      it 'delivers GDPR emails' do
        expect { approve_authorization_request }.to have_enqueued_mail(GDPRContactMailer, :responsable_traitement)
      end

      {
        hubee_cert_dc: HubEECertDCBridge,
        hubee_dila: HubEEDilaBridge,
      }.each do |authorization_request_kind, bridge_class|
        context "when there is a bridge for #{authorization_request_kind}" do
          let(:authorization_request_kind) { authorization_request_kind }

          before do
            allow(bridge_class).to receive(:perform_later)
          end

          it 'executes the bridge asynchronously with approve event' do
            approve_authorization_request

            expect(bridge_class).to have_received(:perform_later).with(authorization_request, :approve)
          end
        end
      end

      context 'when it is a reopening' do
        let!(:authorization_request) { create(:authorization_request, :api_scolarite, :reopened) }

        before do
          authorization_request.update!(state: 'submitted')
        end

        it 'delivers an email specific to reopening' do
          expect { approve_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_approve)
        end
      end

      it 'creates a new authorization with snapshoted data' do
        expect { approve_authorization_request }.to change(Authorization, :count).by(1)

        authorization = Authorization.last

        expect(authorization.applicant).to eq(authorization_request.applicant)
        expect(authorization.organization).to eq(authorization_request.organization)
        expect(authorization.request).to eq(authorization_request)
        expect(authorization.data).to eq(authorization_request.data)
      end

      describe 'when it is an authorization request which is in a stage with previous steps and already an authorization' do
        let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :submitted) }

        before do
          create(:authorization, request: authorization_request)
        end

        it 'creates a new authorization' do
          expect { approve_authorization_request }.to change(Authorization, :count).by(1)
        end
      end

      describe 'when there is attached documents' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, documents: %i[cadre_juridique_document]) }

        it 'creates a new authorization with attached documents' do
          expect { approve_authorization_request }.to change(Authorization, :count).by(1)

          authorization = Authorization.last

          expect(authorization.documents.count).to eq(1)
          expect(authorization.documents.first.files.blobs).to match_array(authorization_request.cadre_juridique_document.blobs)
        end
      end

      it_behaves_like 'creates an event', event_name: :approve, entity_type: :authorization
      it_behaves_like 'delivers a webhook', event_name: :approve

      context 'when authorization request is API Particulier with FranceConnect embedded fields' do
        let(:authorization_request) { create(:authorization_request, :api_particulier_entrouvert_publik, :submitted, :with_france_connect_embedded_fields, fill_all_attributes: true) }

        around do |example|
          ServiceProvider.find('entrouvert').apipfc_enabled = true
          example.run
        ensure
          ServiceProvider.find('entrouvert').apipfc_enabled = false
        end

        it 'creates an auto_generate event for the linked FranceConnect authorization' do
          expect { approve_authorization_request }.to change { AuthorizationRequestEvent.where(name: 'auto_generate').count }.by(1)
        end

        it 'links the auto_generate event to the FranceConnect authorization' do
          approve_authorization_request

          fc_authorization = Authorization.find_by(authorization_request_class: 'AuthorizationRequest::FranceConnect')
          auto_generate_event = AuthorizationRequestEvent.find_by(name: 'auto_generate')

          expect(auto_generate_event.entity).to eq(fc_authorization)
        end
      end

      context 'when authorization request has a custom text-only mailer view (FranceConnect)' do
        subject(:approve_authorization_request) do
          described_class.call(
            authorization_request:,
            user:,
            authorization_message: 'Habilitation validée par l’instructeur.'
          )
        end

        let(:user) { create(:user, :instructor, authorization_request_types: %w[france_connect]) }
        let(:authorization_request) { create(:authorization_request, :france_connect, :submitted) }

        let(:delivered_mail) do
          ActionMailer::Base.deliveries.find { |m| m.to.include?(authorization_request.applicant.email) }
        end

        before do
          perform_enqueued_jobs { approve_authorization_request }
        end

        it 'delivers the custom FranceConnect text view' do
          text_body = delivered_mail.text_part&.body&.decoded || delivered_mail.body.decoded
          expect(text_body).to match('espace.partenaires.franceconnect.gouv.fr')
        end

        it 'does not deliver an HTML part when only the text view is customised' do
          expect(delivered_mail.html_part).to be_nil
        end
      end
    end

    context 'with authorization request in draft state' do
      let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft, data: { what: :ever }) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { approve_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
