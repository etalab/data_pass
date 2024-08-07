RSpec.describe AuthorizationRequestFormPolicy do
  describe '#new?' do
    subject { described_class.new(user_context, authorization_request_form).new? }

    let(:user_context) { UserContext.new(user) }
    let(:user) { create(:user) }

    describe 'HubEE' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-cert-dc') }

      context 'when there already is an authorization_request is archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
