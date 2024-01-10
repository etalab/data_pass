RSpec.describe SubmitAuthorizationRequest do
  describe '.call' do
    subject(:submit_authorization_request) { described_class.call(user: authorization_request.applicant, authorization_request:) }

    context 'with authorization request in draft state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

      it { is_expected.to be_success }

      it 'changes state to submitted' do
        expect { submit_authorization_request }.to change { authorization_request.reload.state }.from('draft').to('submitted')
      end

      include_examples 'creates an event', event_name: :submit
    end

    context 'with authorization request in validated state' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

      it { is_expected.to be_a_failure }
    end
  end
end
