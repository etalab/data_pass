require 'rails_helper'

RSpec.describe Instruction::UpdateUserRights, type: :organizer do
  include ActiveJob::TestHelper

  describe '.call' do
    subject(:update_user_rights) do
      described_class.call(authority: Rights::ManagerAuthority.new(manager), actor: manager, user:, new_roles:)
    end

    let!(:admin_recipient) { create(:user, roles: ['admin']) }
    let(:manager) { create(:user, roles: ['dinum:api_entreprise:manager']) }
    let(:user) { create(:user, roles: initial_roles) }
    let(:initial_roles) { [] }
    let(:new_roles) { %w[dinum:api_entreprise:reporter] }

    it { is_expected.to be_success }

    it 'persists the merged roles on the user' do
      update_user_rights

      expect(user.reload.roles).to eq(%w[dinum:api_entreprise:reporter])
    end

    it 'creates an admin event tagged user_rights_changed_by_manager' do
      expect { update_user_rights }.to change(AdminEvent, :count).by(1)

      event = AdminEvent.last
      expect(event.name).to eq('user_rights_changed_by_manager')
      expect(event.admin).to eq(manager)
      expect(event.entity).to eq(user)
      expect(event.before_attributes).to eq('roles' => [])
      expect(event.after_attributes).to eq('roles' => %w[dinum:api_entreprise:reporter])
    end

    it 'notifies admins with the previous roles snapshot' do
      expect {
        perform_enqueued_jobs { update_user_rights }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    context 'when the user already has roles outside the manager scope' do
      let(:initial_roles) { %w[dinum:api_particulier:instructor] }

      it 'keeps the out-of-scope roles intact' do
        update_user_rights

        expect(user.reload.roles).to match_array(%w[dinum:api_particulier:instructor dinum:api_entreprise:reporter])
      end
    end

    context 'when new_roles tries to introduce a definition the manager does not manage' do
      let(:new_roles) { %w[dinum:api_particulier:reporter] }

      it 'silently drops the out-of-scope role' do
        update_user_rights

        expect(user.reload.roles).to eq([])
      end
    end
  end
end
