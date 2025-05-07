RSpec.describe RequestChangesOnAuthorizationRequest do
  describe '.call' do
    subject(:request_changes_authorization_request) { described_class.call(instructor_modification_request_params:, authorization_request:, user:) }

    let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_cert_dc]) }

    context 'with valid params' do
      let(:instructor_modification_request_params) { attributes_for(:instructor_modification_request) }

      context 'with authorization request in submitted state' do
        let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :submitted) }
        let(:authorization_request_kind) { :hubee_cert_dc }

        it { is_expected.to be_success }

        it 'creates an instructor modification request' do
          expect { request_changes_authorization_request }.to change(InstructorModificationRequest, :count).by(1)
        end

        it 'changes state to request_changes' do
          expect { request_changes_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('changes_requested')
        end

        it 'delivers an email' do
          expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :request_changes)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_request_changes)
          end
        end

        it_behaves_like 'creates an event', event_name: :request_changes, entity_type: :instructor_modification_request
        it_behaves_like 'delivers a webhook', event_name: :request_changes
      end

      context 'with sandbox authorization request' do
        let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :submitted) }

        it 'delivers a request changes email' do
          expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :request_changes)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_request_changes)
          end
        end
      end

      context 'with production authorization request' do
        let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :submitted) }

        it 'delivers a request changes email' do
          expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :request_changes)
        end

        context 'when it is a reopening' do
          let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :reopened) }

          before do
            authorization_request.update!(state: 'submitted')
          end

          it 'delivers an email specific to reopening' do
            expect { request_changes_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :reopening_request_changes)
          end
        end
      end

      context 'with authorization request in draft state' do
        let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { request_changes_authorization_request }.not_to change { authorization_request.reload.state }
        end
      end
    end

    context 'with invalid params' do
      let(:instructor_modification_request_params) { attributes_for(:instructor_modification_request, reason: nil) }
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :submitted) }

      it { is_expected.to be_failure }

      it 'does not create an instructor modification request' do
        expect { request_changes_authorization_request }.not_to change(InstructorModificationRequest, :count)
      end

      it 'does not change state' do
        expect { request_changes_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
