RSpec.describe Admin::MarkUserOrganizationAsVerified, type: :organizer do
  describe '.call' do
    subject(:mark_as_verified) { described_class.call(admin:, organizations_user:, reason:) }

    let(:admin) { create(:user, :admin) }
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:organizations_user) do
      create(:organizations_user, user:, organization:, verified: false, verified_reason: 'manual')
    end
    let(:reason) { 'Vérifié par téléphone' }

    it { is_expected.to be_success }

    it 'creates an admin event' do
      expect {
        mark_as_verified
      }.to change(AdminEvent, :count).by(1)

      admin_event = AdminEvent.last

      expect(admin_event.name).to eq('user_organization_verified')
      expect(admin_event.admin).to eq(admin)
      expect(admin_event.entity).to eq(user)
      expect(admin_event.before_attributes).to eq(
        'organization_id' => organization.id,
        'verified' => false,
        'verified_reason' => 'manual'
      )
      expect(admin_event.after_attributes).to eq(
        'organization_id' => organization.id,
        'verified' => true,
        'verified_reason' => reason
      )
    end

    it 'marks the organizations_user as verified' do
      expect {
        mark_as_verified
      }.to change { organizations_user.reload.verified }.from(false).to(true)
    end

    it 'updates the verified_reason' do
      expect {
        mark_as_verified
      }.to change { organizations_user.reload.verified_reason }.from('manual').to(reason)
    end
  end
end
