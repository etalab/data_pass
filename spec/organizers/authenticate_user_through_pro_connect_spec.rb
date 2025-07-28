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
    end

    it 'creates a current organization relationship' do
      authenticate_user

      org_user = authenticate_user.user.organizations_users.first
      expect(org_user).to be_current
      expect(authenticate_user.user.current_organization).to eq(authenticate_user.organization)
    end

    context 'with MonComptePro identity provider' do
      let(:pro_connect_omniauth_payload) do
        build(
          :proconnect_omniauth_payload,
          siret:,
          data_identity_id: '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
        )
      end

      it 'creates verified organization user relationship' do
        authenticate_user

        org_user = authenticate_user.user.reload.organizations_users.first

        expect(org_user.verified).to be true
      end
    end

    context 'with unverified siret for identity provider' do
      let(:pro_connect_omniauth_payload) do
        build(:proconnect_omniauth_payload,
          siret: '21920023500014',
          data_identity_id: 'e2f397e0-f2a5-4cbb-b19f-8b3b54410c26')
      end

      context 'when there is no verified existing link' do
        it 'sets verified_organization to false' do
          authenticate_user
          org_user = authenticate_user.user.reload.organizations_users.first

          expect(org_user.verified).to be false
        end
      end

      context 'when there is already a link with a verified boolean' do
        let(:user) { create(:user, email: pro_connect_omniauth_payload['info']['email']) }
        let(:organization) { create(:organization, siret:) }
        let!(:verified_organization_user) do
          create(:organizations_user, user:, organization:, verified: true)
        end

        it 'sets verified_organization to false' do
          expect {
            authenticate_user
          }.not_to change { verified_organization_user.reload.verified }
        end
      end
    end
  end
end
