RSpec.describe SubmitAuthorizationRequest do
  describe '.call' do
    subject(:submit_authorization_request) { described_class.call(user: authorization_request.applicant, authorization_request:, authorization_request_params:) }

    let(:authorization_request_params) { nil }

    context 'with authorization request in draft state' do
      context 'with valid authorization request' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

        it { is_expected.to be_success }

        it 'changes state to submitted' do
          expect { submit_authorization_request }.to change { authorization_request.reload.state }.from('draft').to('submitted')
        end

        include_examples 'creates an event', event_name: :submit
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
