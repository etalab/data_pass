RSpec.describe Admin::UpdateUserRoles, type: :organizer do
  describe '.call' do
    subject(:update_user_roles) { described_class.call(admin:, user:, roles:) }

    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user, roles: %w[api_entreprise:reporter]) }
    let(:roles) { %w[api_particulier:instructor admin] }

    before do
      ActiveJob::Base.queue_adapter = :inline
    end

    after do
      ActiveJob::Base.queue_adapter = :test
    end

    it { is_expected.to be_success }

    it 'creates an admin event' do
      expect {
        update_user_roles
      }.to change(AdminEvent, :count).by(1)

      admin_event = AdminEvent.last

      expect(admin_event.name).to eq('user_roles_changed')
      expect(admin_event.admin).to eq(admin)
      expect(admin_event.entity).to eq(user)
      expect(admin_event.before_attributes).to eq('roles' => %w[api_entreprise:reporter])
      expect(admin_event.after_attributes).to eq('roles' => %w[api_particulier:instructor admin])
    end

    it 'updates the user roles' do
      expect {
        update_user_roles
      }.to change { user.reload.roles }.from(%w[api_entreprise:reporter]).to(%w[api_particulier:instructor admin])
    end

    it 'notifies admins for roles update' do
      expect {
        update_user_roles
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    describe 'with invalid roles' do
      context 'when it is an invalid authorization request type' do
        let(:roles) { user.roles + %w[invalid_role:instructor] }

        it 'does not update with this role' do
          expect {
            update_user_roles
          }.not_to change { user.reload.roles }
        end
      end

      context 'when it is an invalid role' do
        let(:roles) { user.roles + %w[api_particulier:invalid_role] }

        it 'does not update with this role' do
          expect {
            update_user_roles
          }.not_to change { user.reload.roles }
        end
      end
    end
  end
end
