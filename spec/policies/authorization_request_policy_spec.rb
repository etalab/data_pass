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

  describe '#manual_transfer?' do
    subject { instance.manual_transfer_from_instructor? }

    context 'with a DGFIP draft production (non-regression test)' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :draft, applicant: user) }
      let(:authorization_request_class) { authorization_request }

      it { is_expected.to be true }
    end
  end

  describe '#reopen?' do
    subject { instance.reopen? }

    let(:authorization_request_class) { authorization_request }

    context 'when there are no authorizations' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, applicant: user) }

      it { is_expected.to be false }
    end

    context 'when there is at least one authorization' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated, applicant: user) }

      context 'when reopening feature is disabled' do
        before do
          allow(authorization_request.definition).to receive(:feature?).with(:reopening).and_return(false)
        end

        it { is_expected.to be false }
      end

      context 'when user is not the applicant or not from the same organization' do
        let(:another_user) { create(:user) }
        let(:user_context) { UserContext.new(another_user) }

        it { is_expected.to be false }
      end

      context 'when user is the request applicant, from the same organization but not authorization applicant' do
        let(:another_user) { create(:user) }
        let(:user_context) { UserContext.new(another_user) }

        before do
          another_user.add_to_organization(authorization_request.organization, verified: true, current: true)
          authorization_request.update!(applicant: another_user)
        end

        it { is_expected.to be true }
      end

      context 'when authorization is not reopenable' do
        context 'when authorization is not active' do
          before do
            authorization_request.latest_authorization.update!(state: 'revoked')
          end

          it { is_expected.to be false }
        end

        context 'when request is currently being reopened' do
          before do
            authorization_request.update!(reopened_at: 1.hour.ago, state: 'draft')
          end

          it { is_expected.to be false }
        end
      end

      context 'when all conditions are met' do
        it { is_expected.to be true }
      end

      context 'with multiple authorizations where one is reopenable' do
        before do
          create(:authorization, request: authorization_request, authorization_request_class: authorization_request.type, state: 'revoked', created_at: 1.day.ago)
        end

        it { is_expected.to be true }
      end
    end
  end
end
