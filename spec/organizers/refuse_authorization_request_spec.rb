RSpec.describe RefuseAuthorizationRequest do
  describe '.call' do
    subject(:refuse_authorization_request) { described_class.call(denial_of_authorization_params:, authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }

    context 'with valid params' do
      let(:denial_of_authorization_params) { attributes_for(:denial_of_authorization) }

      context 'with authorization request in submitted state' do
        let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :submitted) }
        let(:authorization_request_kind) { :api_scolarite }

        it { is_expected.to be_success }

        it 'creates a denial authorization' do
          expect { refuse_authorization_request }.to change(DenialOfAuthorization, :count).by(1)
        end

        it 'affects authorization request to context' do
          expect(refuse_authorization_request.authorization_request).to eq(authorization_request)
        end

        it 'changes state to refused' do
          expect { refuse_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('refused')
        end

        it 'delivers an email' do
          expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :refuse)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_refuse)
          end

          context 'when there was updates on the authorization request' do
            let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :reopened, administrateur_metier_email: 'old@gouv.fr') }

            before do
              authorization_request.administrateur_metier_email = 'new@gouv.fr'
              authorization_request.save!
            end

            it 'reverts to previous data' do
              expect { refuse_authorization_request }.to change { authorization_request.reload.administrateur_metier_email }.from('new@gouv.fr').to('old@gouv.fr')
            end
          end

          it 'changes state to validated (revert to latest valid state)' do
            expect { refuse_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('validated')
          end
        end

        it_behaves_like 'creates an event', event_name: :refuse, entity_type: :denial_of_authorization
        it_behaves_like 'delivers a webhook', event_name: :refuse
      end

      context 'with sandbox authorization request' do
        let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :submitted) }

        it 'delivers a refusal email' do
          expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :refuse)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_refuse)
          end
        end
      end

      context 'with production authorization request' do
        let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :submitted) }

        it 'delivers a refusal email' do
          expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :refuse)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_refuse)
          end
        end
      end

      context 'with authorization request in draft state' do
        let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { refuse_authorization_request }.not_to change { authorization_request.reload.state }
        end
      end
    end

    context 'with invalid params' do
      let(:denial_of_authorization_params) { attributes_for(:denial_of_authorization, reason: nil) }
      let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :submitted) }

      it { is_expected.to be_failure }

      it 'does not create a denial authorization' do
        expect { refuse_authorization_request }.not_to change(DenialOfAuthorization, :count)
      end

      it 'does not change state' do
        expect { refuse_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
