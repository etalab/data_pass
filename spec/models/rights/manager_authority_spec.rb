require 'rails_helper'

RSpec.describe Rights::ManagerAuthority do
  subject(:authority) { described_class.new(user) }

  describe '#allowed_role_types' do
    let(:user) { create(:user) }

    it 'returns reporter, instructor, manager and developer' do
      expect(authority.allowed_role_types).to eq(%w[reporter instructor manager developer])
    end
  end

  describe '#managed_definitions' do
    context 'when the user manages a single definition' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

      it 'returns only that definition' do
        expect(authority.managed_definitions.map(&:id)).to eq(['api_entreprise'])
      end
    end

    context 'when the user has no manager role' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:reporter']) }

      it 'returns no definitions' do
        expect(authority.managed_definitions).to be_empty
      end
    end
  end

  describe '#fd_manager_for?' do
    context 'when the user has an FD-manager role' do
      let(:user) { create(:user, roles: ['dinum:*:manager']) }

      it 'returns true for the matching provider' do
        expect(authority.fd_manager_for?('dinum')).to be true
      end

      it 'returns false for an unrelated provider' do
        expect(authority.fd_manager_for?('dgfip')).to be false
      end
    end

    context 'when the user is only a definition-level manager' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

      it 'returns false' do
        expect(authority.fd_manager_for?('dinum')).to be false
      end
    end
  end

  describe '#can_manage_role?' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

    it 'returns false for the admin role' do
      expect(authority.can_manage_role?('admin')).to be false
    end

    it 'returns false for an invalid role string' do
      expect(authority.can_manage_role?('not-a-role')).to be false
    end

    it 'returns true for an allowed role on a managed scope' do
      expect(authority.can_manage_role?('dinum:api_entreprise:reporter')).to be true
    end

    it 'returns false for an allowed role on a scope the user does not manage' do
      expect(authority.can_manage_role?('dgfip:api_ficoba:reporter')).to be false
    end

    context 'when the user is FD-manager' do
      let(:user) { create(:user, roles: ['dinum:*:manager']) }

      it 'returns true for any definition under that provider' do
        expect(authority.can_manage_role?('dinum:api_entreprise:instructor')).to be true
      end

      it 'returns true for the FD-level role itself' do
        expect(authority.can_manage_role?('dinum:*:manager')).to be true
      end
    end
  end

  describe '#covers_role?' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

    it 'returns false for the admin role' do
      expect(authority.covers_role?('admin')).to be false
    end

    it 'returns false for any role on a scope the user does not manage' do
      expect(authority.covers_role?('dgfip:api_ficoba:reporter')).to be false
    end
  end

  describe '#can_self_edit?' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

    it 'returns false (a manager cannot edit their own rights)' do
      expect(authority.can_self_edit?).to be false
    end
  end

  describe '#visible_users' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }
    let!(:in_scope) { create(:user, roles: ['dinum:api_entreprise:reporter']) }
    let!(:fd_wildcard_only) { create(:user, roles: ['dinum:*:reporter']) }
    let!(:out_of_scope) { create(:user, roles: ['dinum:api_particulier:instructor']) }
    let!(:without_roles) { create(:user, roles: []) }

    it 'lists the users holding a role on a managed definition, FD wildcards included' do
      expect(authority.visible_users).to include(user, in_scope, fd_wildcard_only)
    end

    it 'leaves out the users without any role on a managed definition' do
      expect(authority.visible_users).not_to include(out_of_scope, without_roles)
    end
  end

  describe '#sees?' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

    it 'sees a user listed on the page' do
      expect(authority.sees?(create(:user, roles: ['dinum:*:reporter']))).to be true
    end

    it 'does not see a user outside of the list' do
      expect(authority.sees?(create(:user, roles: ['dinum:api_particulier:instructor']))).to be false
    end
  end

  describe '#edits?' do
    let(:user) { create(:user, roles: ['dinum:api_entreprise:manager']) }

    it 'edits a user holding at least one role it covers' do
      target = create(:user, roles: %w[dinum:api_entreprise:reporter dinum:api_particulier:instructor])

      expect(authority.edits?(target)).to be true
    end

    it 'does not edit a user only holding an FD wildcard role it does not manage' do
      expect(authority.edits?(create(:user, roles: ['dinum:*:reporter']))).to be false
    end

    it 'does not edit a user without any role it covers' do
      expect(authority.edits?(create(:user, roles: ['dinum:api_particulier:instructor']))).to be false
    end

    it 'does not edit a user without any role' do
      expect(authority.edits?(create(:user, roles: []))).to be false
    end

    it 'does not edit its own rights' do
      expect(authority.edits?(user)).to be false
    end

    context 'when the user is FD-manager' do
      let(:user) { create(:user, roles: ['dinum:*:manager']) }

      it 'edits a user only holding an FD wildcard role on its provider' do
        expect(authority.edits?(create(:user, roles: ['dinum:*:reporter']))).to be true
      end
    end
  end

  describe '#authorized_scopes' do
    context 'when the user is FD-manager and definition-manager' do
      let(:user) { create(:user, roles: ['dinum:*:manager', 'dgfip:api_ficoba:manager']) }

      it 'includes both fd-wildcard scopes and definition scopes' do
        expect(authority.authorized_scopes).to include('dinum:*', 'dgfip:api_ficoba')
      end
    end
  end
end
