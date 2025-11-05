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

          context 'when there is an existing production authorization' do
            let!(:existing_production_authorization) do
              create(:authorization, request: authorization_request, authorization_request_class: 'AuthorizationRequest::APIImpotParticulier')
            end
            let(:sandbox_key) { 'volumetrie_approximative' }
            let(:production_key) { 'volumetrie_appels_par_minute' }

            before do
              authorization_request.data[sandbox_key] = '9001'
              authorization_request.data[production_key] = '10'
              authorization_request.save!

              existing_production_authorization.data[sandbox_key] = '9002'
              existing_production_authorization.data[production_key] = '50'
              existing_production_authorization.save!
            end

            it 'copies the existing production authorization data, in order to keep production data up to date, but keep sandbox data' do
              start_next_stage

              authorization_request_after = AuthorizationRequest.find(authorization_request.id).data

              expect(authorization_request_after[sandbox_key]).not_to eq(existing_production_authorization.data[sandbox_key])
              expect(authorization_request_after[production_key]).to eq(existing_production_authorization.data[production_key])
            end
          end

          context 'when there is no existing production authorization' do
            it 'the same data' do
              expect { start_next_stage }.not_to change { AuthorizationRequest.find(authorization_request.id).data }
            end
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

          it_behaves_like 'creates an event', event_name: :start_next_stage
          # include_examples 'delivers a notification', event_name: :start_next_stage
        end
      end
    end
  end
end
