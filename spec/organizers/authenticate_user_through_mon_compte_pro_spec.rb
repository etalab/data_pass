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

    it 'associates the user to organization' do
      authenticate_user

      expect(authenticate_user.user.organizations).to include(authenticate_user.organization)
    end

    context 'when user already exists and have another current organization' do
      let!(:user) do
        create(:user, email: mon_compte_pro_omniauth_payload['info']['email'], skip_organization_creation: true).tap do |u|
          u.add_to_organization(create(:organization), current: true)
        end
      end

      it 'changes the current organization' do
        expect {
          authenticate_user
        }.to change { user.reload.current_organization }

        expect(user.current_organization).to eq(authenticate_user.organization)
      end
    end
  end
end
