RSpec.describe AuthenticateUserThroughProConnect do
  describe '#call' do
    subject(:authenticate_user) { described_class.call(pro_connect_omniauth_payload:) }

    let(:pro_connect_omniauth_payload) { build(:proconnect_omniauth_payload, siret:) }
    let(:siret) { '21920023500014' }

    it { is_expected.to be_a_success }

    it 'creates a user and organization' do
      expect { authenticate_user }.to change(User, :count).by(1)
        .and change(Organization, :count).by(1)
    end

    it 'sets the correct identity_provider_uid' do
      authenticate_user

      org_user = authenticate_user.user.organizations_users.first
      expected_idp_id = pro_connect_omniauth_payload.dig('extra', 'raw_info', 'idp_id')
      expect(org_user.identity_provider_uid).to eq(expected_idp_id)
      expect(org_user.identity_federator).to eq('pro_connect')
    end

    it 'creates a current organization relationship' do
      authenticate_user

      org_user = authenticate_user.user.organizations_users.first
      expect(org_user).to be_current
      expect(authenticate_user.user.current_organization).to eq(authenticate_user.organization)
    end

    context 'when an applicant was created beforehand by the API with the same email' do
      let!(:api_applicant) do
        ProvisionApplicantFromAPI.call(
          applicant_params: { email: 'api-applicant@example.com', given_name: 'Jeanne', family_name: 'Martin' },
          siret:
        ).applicant
      end
      let!(:draft) do
        create(:authorization_request, :api_entreprise, applicant: api_applicant, organization: api_applicant.organizations.first, state: 'draft')
      end
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload, siret:).tap do |payload|
          payload['extra']['raw_info']['email'] = 'API-Applicant@example.com'
        end
      end

      it 'completes the existing account instead of creating a duplicate' do
        expect { authenticate_user }.not_to change(User, :count)

        expect(authenticate_user.user.id).to eq(api_applicant.id)
        expect(api_applicant.reload.external_id).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'sub'))
      end

      it 'keeps the drafts attached to the account' do
        authenticate_user

        expect(draft.reload.applicant).to eq(api_applicant)
      end

      it 'completes the organization link with the ProConnect federator' do
        authenticate_user

        link = api_applicant.organizations_users.find_by(organization: draft.organization)

        expect(link.identity_federator).to eq('pro_connect')
        expect(link.identity_provider_uid).to be_present
      end

      context 'when the identity provider verifies the SIRET' do
        let(:pro_connect_omniauth_payload) do
          build(:proconnect_omniauth_payload, siret:, data_identity_id: '71144ab3-ee1a-4401-b7b3-79b44f7daeeb').tap do |payload|
            payload['extra']['raw_info']['email'] = 'API-Applicant@example.com'
          end
        end

        it 'starts with an unverified link' do
          expect(api_applicant.organizations_users.sole).not_to be_verified
        end

        it 'verifies the existing link instead of creating another one' do
          link = api_applicant.organizations_users.sole

          expect { authenticate_user }.not_to change(OrganizationsUser, :count)

          expect(link.reload).to be_verified
          expect(link.verified_reason).to eq('from ProConnect identity')
        end
      end

      context 'when the identity provider does not verify the SIRET' do
        let(:pro_connect_omniauth_payload) do
          build(:proconnect_omniauth_payload, siret:, data_identity_id: 'e2f397e0-f2a5-4cbb-b19f-8b3b54410c26').tap do |payload|
            payload['extra']['raw_info']['email'] = 'API-Applicant@example.com'
          end
        end

        it 'keeps the link unverified' do
          link = api_applicant.organizations_users.sole

          expect { authenticate_user }.not_to change(OrganizationsUser, :count)

          expect(link.reload).not_to be_verified
          expect(link.identity_federator).to eq('pro_connect')
        end
      end
    end

    context 'when a returning ProConnect user logs in' do
      let(:sub) { 'returning-sub' }
      let!(:returning_user) { create(:user, email: 'returning@example.com', external_id: sub) }
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload, siret:).tap do |payload|
          payload['extra']['raw_info']['email'] = 'Returning@example.com'
          payload['extra']['raw_info']['sub'] = sub
        end
      end

      it 'logs in the same account without duplicate' do
        expect { authenticate_user }.not_to change(User, :count)

        expect(authenticate_user).to be_a_success
        expect(authenticate_user.user).to eq(returning_user)
      end
    end

    context 'when the ProConnect sub belongs to an account with another email' do
      let(:sub) { 'sub-already-known' }
      let!(:previous_account) { create(:user, email: 'old-address@example.com', external_id: sub) }
      let(:new_email) { 'new-address@example.com' }
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload, siret:).tap do |payload|
          payload['extra']['raw_info']['email'] = new_email
          payload['extra']['raw_info']['sub'] = sub
        end
      end

      it 'fails cleanly without creating an account or an organization link' do
        expect { authenticate_user }.not_to change { [User.count, OrganizationsUser.count] }

        expect(authenticate_user).to be_a_failure
        expect(authenticate_user.error[:key]).to eq(:user_email_mismatch)
        expect(previous_account.reload.email).to eq('old-address@example.com')
      end

      context 'when the new email belongs to an API-created account' do
        let(:new_email) { 'api-applicant@example.com' }
        let!(:api_applicant) do
          ProvisionApplicantFromAPI.call(
            applicant_params: { email: new_email },
            siret:
          ).applicant
        end

        it 'fails without writing anything' do
          expect { authenticate_user }.not_to change(OrganizationsUser, :count)

          expect(authenticate_user).to be_a_failure
          expect(api_applicant.reload.external_id).to be_nil
          expect(previous_account.reload.external_id).to eq(sub)
        end
      end
    end

    context 'when the payload has no sub and an API-created account exists with another email' do
      let!(:api_applicant) do
        ProvisionApplicantFromAPI.call(
          applicant_params: { email: 'api-applicant@example.com' },
          siret:
        ).applicant
      end
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload, siret:).tap do |payload|
          payload['extra']['raw_info']['sub'] = nil
        end
      end

      it 'does not log in nor modify the API-created account' do
        expect { authenticate_user }.not_to change { api_applicant.reload.attributes }

        expect(authenticate_user.user).not_to eq(api_applicant)
        expect(authenticate_user.user.external_id).to be_nil
      end
    end

    context 'with MonComptePro identity provider' do
      let(:pro_connect_omniauth_payload) do
        build(
          :proconnect_omniauth_payload,
          siret:,
          data_identity_id: '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
        )
      end

      it 'creates verified organization user relationship with reason' do
        authenticate_user

        org_user = authenticate_user.user.reload.organizations_users.first

        expect(org_user.verified).to be true
        expect(org_user.verified_reason).to eq('from ProConnect identity')
      end
    end

    context 'with unverified siret for identity provider' do
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload,
          siret: '21920023500014',
          data_identity_id: 'e2f397e0-f2a5-4cbb-b19f-8b3b54410c26')
      end

      context 'when there is no verified existing link' do
        it 'sets verified to false without reason' do
          authenticate_user
          org_user = authenticate_user.user.reload.organizations_users.first

          expect(org_user.verified).to be false
          expect(org_user.verified_reason).to be_nil
        end
      end

      context 'when there is already a link with a verified boolean' do
        let(:user) { create(:user, email: pro_connect_omniauth_payload['info']['email']) }
        let(:organization) { create(:organization, siret:) }
        let!(:verified_organization_user) do
          create(:organizations_user, user:, organization:, verified: true)
        end

        it 'does not change verified_organization boolean' do
          expect {
            authenticate_user
          }.not_to change { verified_organization_user.reload.verified }
        end
      end
    end
  end
end
