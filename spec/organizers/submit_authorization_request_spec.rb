RSpec.describe SubmitAuthorizationRequest do
  describe '.call' do
    subject(:submit_authorization_request) { described_class.call(user: authorization_request.applicant, authorization_request:, authorization_request_params:) }

    let(:authorization_request_params) { nil }

    context 'with authorization request in draft state' do
      context 'with valid authorization request' do
        let(:authorization_request) { create(:authorization_request, authorization_request_kind, :draft, fill_all_attributes: true) }
        let(:authorization_request_kind) { :api_entreprise }

        it { is_expected.to be_success }

        it 'changes state to submitted' do
          expect { submit_authorization_request }.to change { authorization_request.reload.state }.from('draft').to('submitted')
        end

        it 'changes last_submitted_at to now' do
          expect { submit_authorization_request }.to change { authorization_request.reload.last_submitted_at }.to(be_within(1.second).of(Time.current))
        end

        include_examples 'creates an event', event_name: :submit
        include_examples 'delivers a webhook', event_name: :submit

        it 'creates a changelog' do
          expect { submit_authorization_request }.to change { authorization_request.changelogs.count }.by(1)
        end

        it 'notifies the instructors' do
          expect { submit_authorization_request }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit)
        end
      end

      context 'with invalid params' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        let(:authorization_request_params) { ActionController::Parameters.new(intitule: '') }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end

        it 'does not updates params' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.intitule }
        end
      end

      context 'with missing checkbox' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        before do
          authorization_request.update!(terms_of_service_accepted: false)
        end

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end

        it 'does not updates params' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.intitule }
        end
      end

      context 'with invalid authorization request' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { submit_authorization_request }.not_to change { authorization_request.reload.state }
        end

        it 'does not create an event' do
          expect { submit_authorization_request }.not_to change { authorization_request.events.count }
        end
      end
    end

    context 'with authorization request in validated state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it { is_expected.to be_a_failure }

      it 'does not create an event' do
        expect { submit_authorization_request }.not_to change { authorization_request.events.count }
      end
    end
  end
end
