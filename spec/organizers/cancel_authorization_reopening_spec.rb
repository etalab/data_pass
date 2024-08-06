RSpec.describe CancelAuthorizationReopening, type: :organizer do
  describe '.call' do
    subject(:cancel_authorization_reopening) { described_class.call(authorization_request:, user:, reason:) }

    let!(:authorization_request) { create(:authorization_request, kind, :reopened) }
    let(:kind) { :hubee_cert_dc }
    let(:reason) { 'Too old mate' }

    context 'when user is an instructor' do
      let(:user) { create(:user, :instructor, authorization_request_types: [kind]) }

      context 'with valid attributes' do
        it { is_expected.to be_success }

        it 'create an authorization request reopening cancellation' do
          expect { cancel_authorization_reopening }.to change(AuthorizationRequestReopeningCancellation, :count).by(1)
        end

        it 'changes authorization request state to validated' do
          expect { cancel_authorization_reopening }.to change { authorization_request.reload.state }.from('draft').to('validated')
        end

        context 'when there was changes on the authorization request' do
          let!(:authorization_request) { create(:authorization_request, kind, :reopened, administrateur_metier_email: 'old@gouv.fr') }

          before do
            authorization_request.administrateur_metier_email = 'new@gouv.fr'
            authorization_request.save!
          end

          it 'reverts attributes to latest authorization data' do
            expect { cancel_authorization_reopening }.to change { authorization_request.reload.administrateur_metier_email }.from('new@gouv.fr').to('old@gouv.fr')
          end
        end

        include_examples 'creates an event', event_name: :cancel_reopening, entity_type: :authorization_request_reopening_cancellation

        context 'when authorization request has webhooks activated' do
          let(:kind) { :api_entreprise }

          it 'delivers a webhook for transfer event' do
            expect { subject }.to have_enqueued_job(DeliverAuthorizationRequestWebhookJob).with(
              authorization_request.definition.id,
              a_string_matching('"event":"cancel_reopening"'),
              authorization_request.id,
            )
          end
        end
      end

      context 'with invalid attributes' do
        let(:reason) { nil }

        it { is_expected.to be_failure }

        it 'does not create an authorization request reopening cancellation' do
          expect { cancel_authorization_reopening }.not_to change(AuthorizationRequestReopeningCancellation, :count)
        end

        it 'does not change authorization request state' do
          expect { cancel_authorization_reopening }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { cancel_authorization_reopening }.not_to change(AuthorizationRequestEvent, :count)
        end
      end
    end
  end

  context 'when it is the applicant' do
    xit 'works'
  end
end