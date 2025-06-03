RSpec.describe AuthenticateUserThroughProConnect do
  describe '#call' do
    subject(:authenticate_user) { described_class.call(pro_connect_omniauth_payload:) }

    let(:pro_connect_omniauth_payload) { build(:proconnect_omniauth_payload, siret: '21920023500014') }

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
  end
end
