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

    context 'when user already exists and have another current organization' do
      let!(:user) { create(:user, external_id: mon_compte_pro_omniauth_payload['uid'], email: mon_compte_pro_omniauth_payload['info']['email']) }

      it 'changes the current organization' do
        expect {
          authenticate_user
        }.to change { user.reload.current_organization }

        expect(user.current_organization).to eq(authenticate_user.organization)
      end
    end
  end
end
