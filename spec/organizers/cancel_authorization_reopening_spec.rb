RSpec.describe CancelAuthorizationReopening, type: :organizer do
  describe '.call' do
    subject(:cancel_authorization_reopening) { described_class.call(**params) }

    let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :reopened) }
    let(:authorization_request_kind) { :hubee_cert_dc }
    let(:authorization_request_reopening_cancellation_params) { { reason: } }
    let(:params) { { authorization_request:, user:, authorization_request_reopening_cancellation_params: } }
    let(:reason) { 'Too old mate' }

    context 'when user is an instructor' do
      let(:user) { create(:user, :instructor, authorization_request_types: [authorization_request_kind]) }

      context 'with valid attributes' do
        it { is_expected.to be_success }

        it 'create an authorization request reopening cancellation' do
          expect { cancel_authorization_reopening }.to change(AuthorizationRequestReopeningCancellation, :count).by(1)
        end

        it 'changes authorization request state to validated' do
          expect { cancel_authorization_reopening }.to change { authorization_request.reload.state }.from('draft').to('validated')
        end

        context 'when there was changes on the authorization request' do
          let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :reopened, administrateur_metier_email: 'old@gouv.fr') }

          before do
            authorization_request.administrateur_metier_email = 'new@gouv.fr'
            authorization_request.save!
          end

          it 'reverts attributes to latest authorization data' do
            expect { cancel_authorization_reopening }.to change { authorization_request.reload.administrateur_metier_email }.from('new@gouv.fr').to('old@gouv.fr')
          end

          describe 'when there are changes between the latest authorization keys and the actual authorization request' do
            let(:authorization) { authorization_request.latest_authorization }

            before do
              authorization.data['responsable_traitement_email'] = 'user@gouv.fr'
              authorization.data.delete 'administrateur_metier_email'
              authorization.save!
            end

            it { is_expected.to be_success }

            it 'changes authorization request state to validated' do
              expect { cancel_authorization_reopening }.to change { authorization_request.reload.state }.from('draft').to('validated')
            end

            it 'does not update on old keys' do
              expect { cancel_authorization_reopening }.not_to change { authorization_request.data['responsable_traitement_email'] }
            end

            it 'does not update on keys missing from the snapshot' do
              expect { cancel_authorization_reopening }.not_to change { authorization_request.data['administrateur_metier_email'] }
            end
          end
        end

        include_examples 'creates an event', event_name: :cancel_reopening, entity_type: :authorization_request_reopening_cancellation
        include_examples 'delivers a webhook', event_name: :cancel_reopening
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

    context 'when it is the applicant' do
      let(:authorization_request_reopening_cancellation_params) { nil }
      let(:user) { authorization_request.applicant }

      context 'with valid attributes' do
        it { is_expected.to be_success }

        it 'create an authorization request reopening cancellation' do
          expect { cancel_authorization_reopening }.to change(AuthorizationRequestReopeningCancellation, :count).by(1)
        end

        it 'changes authorization request state to validated' do
          expect { cancel_authorization_reopening }.to change { authorization_request.reload.state }.from('draft').to('validated')
        end

        context 'when there was changes on the authorization request' do
          let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :reopened, administrateur_metier_email: 'old@gouv.fr') }

          before do
            authorization_request.administrateur_metier_email = 'new@gouv.fr'
            authorization_request.save!
          end

          it 'reverts attributes to latest authorization data' do
            expect { cancel_authorization_reopening }.to change { authorization_request.reload.administrateur_metier_email }.from('new@gouv.fr').to('old@gouv.fr')
          end
        end

        include_examples 'creates an event', event_name: :cancel_reopening, entity_type: :authorization_request_reopening_cancellation
        include_examples 'delivers a webhook', event_name: :cancel_reopening
      end

      context 'with invalid attributes' do
        let(:user) { nil }

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
end
