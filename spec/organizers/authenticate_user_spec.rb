RSpec.describe AuthenticateUser do
  describe '#call' do
    subject(:authenticate_user) { described_class.call(mon_compte_pro_omniauth_payload:) }

    let(:mon_compte_pro_omniauth_payload) { build(:mon_compte_pro_omniauth_payload) }

    it { is_expected.to be_a_success }

    it 'creates a new user' do
      expect { subject }.to change(User, :count).by(1)
    end

    it 'creates a new organization' do
      expect { subject }.to change(Organization, :count).by(1)
    end

    it 'associates the user to organization' do
      authenticate_user

      expect(authenticate_user.user.organizations).to include(authenticate_user.organization)
    end
  end
end
