RSpec.describe TransferAuthorizationRequestToNewApplicant, type: :organizer do
  describe '.call' do
    subject { described_class.call(authorization_request:, new_applicant:, user:) }

    let(:organization) { authorization_request.organization }
    let(:authorization_request) { create(:authorization_request, authorization_request_kind) }
    let(:authorization_request_kind) { :api_service_national }
    let!(:old_applicant) { authorization_request.applicant }
    let(:new_applicant) { create(:user, current_organization: organization) }
    let(:user) { create(:user) }

    context 'with valid attributes' do
      it { is_expected.to be_success }

      it 'transfers the authorization request to the new applicant' do
        expect { subject }.to change { authorization_request.reload.applicant }.from(authorization_request.applicant).to(new_applicant)
      end

      it 'creates a new authorization request transfer with valid attributes' do
        expect { subject }.to change(AuthorizationRequestTransfer, :count).by(1)

        expect(AuthorizationRequestTransfer.last).to have_attributes(
          authorization_request:,
          from: old_applicant,
          to: new_applicant,
        )
      end

      include_examples 'creates an event', event_name: 'transfer', entity: :authorization_request_transfer
      include_examples 'delivers a webhook', event_name: 'transfer'
    end

    context 'with invalid attributes' do
      let(:new_applicant) { create(:user) }

      it { is_expected.to be_failure }

      it 'does not transfer the authorization request to the new applicant' do
        expect { subject }.not_to change { authorization_request.reload.applicant }
      end

      it 'does not create a new authorization request transfer' do
        expect { subject }.not_to change(AuthorizationRequestTransfer, :count)
      end

      it 'does not create an event' do
        expect { subject }.not_to change(AuthorizationRequestEvent, :count)
      end
    end
  end
end
