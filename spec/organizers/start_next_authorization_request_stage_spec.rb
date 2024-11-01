RSpec.describe StartNextAuthorizationRequestStage, type: :organizer do
  describe '#call' do
    subject(:start_next_stage) { described_class.call(authorization_request: authorization_request, user: authorization_request.applicant) }

    context 'when authorization request has no stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it { is_expected.to be_failure }
    end

    context 'when authorization request has a stage' do
      context 'when this stage is production' do
        let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }

        it { is_expected.to be_failure }
      end

      context 'when this stage is sandbox' do
        context 'when authorization request is not validated' do
          let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :submitted) }

          it { is_expected.to be_failure }
        end

        context 'when authorization request is validated' do
          let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :validated) }

          it { is_expected.to be_success }

          it 'converts the authorization request to production stage type' do
            expect { start_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).type }.from('AuthorizationRequest::APIImpotParticulierSandbox').to('AuthorizationRequest::APIImpotParticulier')
          end

          it 'changes state from validated to draft' do
            expect { start_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).state }.from('validated').to('draft')
          end

          it 'copy keeps the same data' do
            expect { start_next_stage }.not_to change { AuthorizationRequest.find(authorization_request.id).data }
          end

          it 'changes form id' do
            expect { start_next_stage }.to change { AuthorizationRequest.find(authorization_request.id).form_uid }
          end

          it 'resets checkboxes' do
            start_next_stage

            AuthorizationRequest.find(authorization_request.id)

            expect(authorization_request.terms_of_service_accepted).to be_falsey
            expect(authorization_request.data_protection_officer_informed).to be_falsey
          end

          include_examples 'creates an event', event_name: :start_next_stage
          # include_examples 'delivers a notification', event_name: :start_next_stage
        end
      end
    end
  end
end
