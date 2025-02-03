RSpec.describe Admin::UpdateUserRoles, type: :organizer do
  describe '.call' do
    subject(:update_user_roles) { described_class.call(admin:, user:, roles:) }

    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user, roles: %w[old_role:reporter]) }
    let(:roles) { %w[new_role:instructor] }

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
      expect(admin_event.before_attributes).to eq('roles' => %w[old_role:reporter])
      expect(admin_event.after_attributes).to eq('roles' => %w[new_role:instructor])
    end

    it 'updates the user roles' do
      expect {
        update_user_roles
      }.to change { user.reload.roles }.from(%w[old_role:reporter]).to(%w[new_role:instructor])
    end

    it 'notifies admins for roles update' do
      expect {
        update_user_roles
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
