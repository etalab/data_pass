RSpec.describe AuthenticateUserThroughMonComptePro do
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

    it 'schedules a job to update organization INSEE data' do
      expect { subject }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
    end

    it 'associates the user to organization, and marks it as verified' do
      authenticate_user

      expect(authenticate_user.user.reload.organizations).to include(authenticate_user.organization)
      expect(authenticate_user.user.organizations_users.first.verified).to be_truthy
      expect(authenticate_user.user.organizations_users.first.identity_federator).to eq('mon_compte_pro')
      expect(authenticate_user.user.organizations_users.first.identity_provider_uid).to eq(IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID)
    end

    context 'when user already exists and have another current organization' do
      let!(:user) do
        create(:user, email: mon_compte_pro_omniauth_payload['info']['email'], skip_organization_creation: true).tap do |u|
          u.add_to_organization(create(:organization), current: true, verified: true)
        end
      end

      it 'changes the current organization' do
        expect {
          authenticate_user
        }.to change { user.reload.current_organization }

        expect(user.current_organization).to eq(authenticate_user.organization)
      end
    end

    context 'when user already exists with same external ID but another email' do
      let!(:another_user) do
        create(:user, external_id: mon_compte_pro_omniauth_payload['info']['sub'], email: generate(:email))
      end

      it 'does not create a new user and updated the existing one' do
        expect { authenticate_user }.not_to change(User, :count)

        expect(another_user.reload.email).to eq(mon_compte_pro_omniauth_payload['info']['email'])
      end
    end
  end
end
