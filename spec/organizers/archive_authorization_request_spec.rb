RSpec.describe ArchiveAuthorizationRequest do
  describe '.call' do
    subject(:archive_authorization_request) { described_class.call(authorization_request:, user:) }

    let(:user) { create(:user) }

    context 'with authorization request in draft state' do
      let!(:authorization_request) { create(:authorization_request, authorization_request_kind, :draft) }
      let(:authorization_request_kind) { :hubee_cert_dc }

      it { is_expected.to be_success }

      it 'changes state to archived' do
        expect { archive_authorization_request }.to change { authorization_request.reload.state }.from('draft').to('archived')
      end

      it_behaves_like 'creates an event', event_name: :archive
      it_behaves_like 'delivers a webhook', event_name: :archive
    end

    context 'with authorization request in validated state' do
      let!(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated) }

      it { is_expected.to be_failure }

      it 'does not change state' do
        expect { archive_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
