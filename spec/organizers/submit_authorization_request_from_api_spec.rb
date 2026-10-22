RSpec.describe SubmitAuthorizationRequestFromAPI, type: :organizer do
  describe '.call' do
    subject(:result) { described_class.call(authorization_request:, consentement:) }

    let(:consentement) do
      ActionController::Parameters.new(
        terms_of_service_accepted: true,
        data_protection_officer_informed: true
      )
    end
    let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    context 'with a complete draft and every consent given' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

      before do
        authorization_request.update!(terms_of_service_accepted: false, data_protection_officer_informed: false)
      end

      it { is_expected.to be_success }

      it 'submits the authorization request' do
        expect { result }.to change { authorization_request.reload.state }.from('draft').to('submitted')
      end

      it 'records the submission on behalf of the applicant' do
        result

        expect(authorization_request.events.where(name: 'submit').last.user).to eq(authorization_request.applicant)
      end

      it_behaves_like 'creates an event', event_name: :submit
      it_behaves_like 'delivers a webhook', event_name: :submit

      it 'notifies the instructors like a regular submission' do
        expect { result }.to have_enqueued_mail(Instruction::AuthorizationRequestMailer, :submit)
      end
    end

    context 'with a request that needs changes' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :changes_requested, fill_all_attributes: true) }

      it { is_expected.to be_success }

      it 'submits the authorization request again' do
        expect { result }.to change { authorization_request.reload.state }.from('changes_requested').to('submitted')
      end
    end

    context 'when a required consent is missing' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }
      let(:consentement) { ActionController::Parameters.new(terms_of_service_accepted: true) }

      it { is_expected.to be_failure }

      it 'names the missing consent' do
        expect(result.error).to include(key: :consent_missing, errors: %i[data_protection_officer_informed])
      end

      it 'does not change the state' do
        expect { result }.not_to change { authorization_request.reload.state }
      end

      it 'does not create an event' do
        expect { result }.not_to change { authorization_request.events.count }
      end
    end

    context 'when a required consent is explicitly refused' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }
      let(:consentement) do
        ActionController::Parameters.new(terms_of_service_accepted: false, data_protection_officer_informed: true)
      end

      it { is_expected.to be_failure }

      it 'names the refused consent' do
        expect(result.error).to include(key: :consent_missing, errors: %i[terms_of_service_accepted])
      end
    end

    context 'when the consent was given earlier but is not transmitted again' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }
      let(:consentement) { ActionController::Parameters.new({}) }

      it { is_expected.to be_failure }
    end

    context 'with an incomplete draft' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

      it { is_expected.to be_failure }

      it 'reports the invalid request' do
        expect(result.error[:key]).to eq(:authorization_request_invalid)
      end

      it 'keeps the draft' do
        expect { result }.not_to change { authorization_request.reload.state }
      end
    end

    %i[submitted validated refused].each do |state|
      context "with a request in #{state} state" do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, state) }

        it { is_expected.to be_failure }

        it 'reports a state that cannot be modified' do
          expect(result.error[:key]).to eq(:dead_end_state)
        end

        it 'does not change the state' do
          expect { result }.not_to change { authorization_request.reload.state }
        end
      end
    end
  end
end
