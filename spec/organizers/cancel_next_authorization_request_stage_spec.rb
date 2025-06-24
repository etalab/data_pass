RSpec.describe CancelNextAuthorizationRequestStage, type: :organizer do
  describe '#call' do
    subject(:cancel_next_stage) { described_class.call(authorization_request: authorization_request, user: authorization_request.applicant) }

    context 'when authorization request has no stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

      it { is_expected.to be_failure }

      it 'does not transition the authorization request' do
        expect { cancel_next_stage }.not_to change { authorization_request.reload.state }
      end
    end

    context 'when authorization request has a stage' do
      context 'when this stage is production' do
        context 'when in draft state' do
          let(:authorization_request) { create(:authorization_request, :api_impot_particulier_stationnement_residentiel_production, :draft, terms_of_service_accepted: false) }

          it { is_expected.to be_success }

          it 'transitions the authorization request from draft to validated' do
            expect { cancel_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).state }.from('draft').to('validated')
          end

          it 'converts the authorization request back to sandbox stage type' do
            expect { cancel_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).type }.from('AuthorizationRequest::APIImpotParticulier').to('AuthorizationRequest::APIImpotParticulierSandbox')
          end

          it 'changes form id to valid previous form uid' do
            expect { cancel_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).form_uid }.from('api-impot-particulier-stationnement-residentiel-production').to('api-impot-particulier-stationnement-residentiel-sandbox')
          end

          it 'resets checkboxes' do
            cancel_next_stage

            reloaded_authorization_request = AuthorizationRequest.find(authorization_request.id)

            expect(reloaded_authorization_request.terms_of_service_accepted).to be(true)
            expect(reloaded_authorization_request.data_protection_officer_informed).to be(true)
          end

          it_behaves_like 'creates an event', event_name: :cancel_next_stage
        end

        context 'when in validated state' do
          let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }

          it { is_expected.to be_failure }

          it 'does not transition the authorization request' do
            expect { cancel_next_stage }.not_to change { authorization_request.reload.state }
          end
        end
      end

      context 'when this stage is sandbox' do
        let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :draft) }

        it { is_expected.to be_failure }

        it 'does not transition the authorization request' do
          expect { cancel_next_stage }.not_to change { authorization_request.reload.state }
        end
      end
    end
  end
end
