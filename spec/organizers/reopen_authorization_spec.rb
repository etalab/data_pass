RSpec.describe ReopenAuthorization do
  describe '.call' do
    subject(:reopen_authorization_request) { described_class.call(authorization:, user:) }

    let(:user) { authorization_request.applicant }
    let(:authorization) { create(:authorization, request: authorization_request) }

    before do
      freeze_time
    end

    context 'with authorization request is in validated state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it { is_expected.to be_success }

      it 'changes state to draft' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.state }.from('validated').to('draft')
      end

      it 'updates reopened_at to now' do
        expect { reopen_authorization_request }.to change { authorization_request.reload.reopened_at.try(:to_i) }.from(nil).to(Time.zone.now.to_i)
      end

      include_examples 'creates an event', event_name: :reopen, entity_type: :authorization
    end

    context 'with authorization request in draft state' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :draft) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { reopen_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
