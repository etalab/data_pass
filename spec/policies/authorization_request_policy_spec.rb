RSpec.describe AuthorizationRequestPolicy do
  let(:instance) { described_class.new(user_context, authorization_request_class) }
  let(:user_context) { UserContext.new(user) }
  let(:user) { create(:user) }

  describe '#new?' do
    subject { instance.new? }

    describe 'HubEE' do
      let(:authorization_request_class) { AuthorizationRequest::HubEECertDC }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#create?' do
    subject { instance.create? }

    describe 'HubEE CertDC' do
      let(:authorization_request_class) { AuthorizationRequest::HubEECertDC }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_falsey }
      end

      context 'when there already is another authorization_request refused' do
        before { create(:authorization_request, :hubee_cert_dc, :refused, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request revoked' do
        before { create(:authorization_request, :hubee_cert_dc, :revoked, applicant: user) }

        it { is_expected.to be_truthy }
      end
    end

    describe 'HubEE DILA' do
      let(:authorization_request_class) { AuthorizationRequest::HubEEDila }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_dila, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_dila, applicant: user) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#submit_reopening?' do
    subject { instance.submit_reopening? }

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, applicant: user) }
    let(:authorization_request_class) { authorization_request }

    context 'when the user is from another organization' do
      let(:another_user) { create(:user) }
      let(:user_context) { UserContext.new(another_user) }

      it { is_expected.to be false }
    end

    context 'when the user is from the same organization' do
      context 'when data has not changed' do
        it { is_expected.to be false }
      end

      context 'when data has changed' do
        before do
          authorization_request.data['intitule'] = 'Meilleur titre'
        end

        it { is_expected.to be true }
      end
    end
  end
end
