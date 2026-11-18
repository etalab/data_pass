RSpec.describe TransferAuthorizationRequestToNewOrganization, type: :organizer do
  describe '.call' do
    subject { described_class.call(authorization_request:, new_organization:, new_applicant:, user:) }

    let(:authorization_request) { create(:authorization_request, authorization_request_kind) }
    let(:authorization_request_kind) { :api_scolarite }
    let!(:old_organization) { authorization_request.organization }
    let(:new_organization) { create(:organization) }
    let(:new_applicant) { create(:user, current_organization: new_organization) }
    let(:user) { create(:user) }

    context 'with valid attributes' do
      it { is_expected.to be_success }

      it 'transfers the authorization request to the new organization' do
        expect { subject }.to change { authorization_request.reload.organization }.from(authorization_request.organization).to(new_organization)
      end

      it 'creates a new authorization request transfer with valid attributes' do
        expect { subject }.to change(AuthorizationRequestTransfer, :count).by(1)

        expect(AuthorizationRequestTransfer.last).to have_attributes(
          authorization_request:,
          from: old_organization,
          to: new_organization,
        )
      end

      it 'keeps the metadata of every namespace' do
        metadata = { 'api' => { 'campagne' => 'migration-editeur-x' }, 'datapass' => { 'note' => 'interne' } }
        authorization_request.update!(metadata:)

        subject

        expect(authorization_request.reload.metadata).to eq(metadata)
      end

      it_behaves_like 'creates an event', event_name: 'transfer', entity_type: :authorization_request_transfer
      it_behaves_like 'delivers a webhook', event_name: 'transfer'
    end

    context 'with invalid attributes' do
      let(:new_applicant) { create(:user) }

      it { is_expected.to be_failure }

      it 'does not transfer the authorization request to the new organization' do
        expect { subject }.not_to change { authorization_request.reload.organization }
      end

      it 'does not create a new authorization request transfer' do
        expect { subject }.not_to change(AuthorizationRequestTransfer, :count)
      end

      it 'does not create an event' do
        expect { subject }.not_to change(AuthorizationRequestEvent, :count)
      end
    end
  end

  describe 'when the last step fails' do
    subject(:transfer_authorization_request) { described_class.call(authorization_request:, new_organization:, new_applicant: create(:user, current_organization: new_organization), user: create(:user)) }

    let!(:authorization_request) { create(:authorization_request, :api_scolarite) }
    let(:new_organization) { create(:organization) }

    LateFailureHelpers::FAILURE_MODES.each do |failure, mode|
      context "with #{failure} in DeliverAuthorizationRequestNotification" do
        before { make_step_fail(DeliverAuthorizationRequestNotification, mode) }

        it 'writes nothing' do
          expect { call_through_late_failure { transfer_authorization_request } }.to not_change(AuthorizationRequestTransfer, :count)
            .and not_change(AuthorizationRequestEvent, :count)

          expect(authorization_request.reload.organization).not_to eq(new_organization)
        end
      end
    end
  end
end
