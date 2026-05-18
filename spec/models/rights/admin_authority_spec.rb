require 'rails_helper'

RSpec.describe Rights::AdminAuthority do
  subject(:authority) { described_class.new(user) }

  let(:user) { create(:user, roles: ['admin']) }

  describe '#allowed_role_types' do
    it 'includes developer in addition to manager-level roles' do
      expect(authority.allowed_role_types).to eq(%w[reporter instructor manager developer])
    end

    it 'does not include admin' do
      expect(authority.allowed_role_types).not_to include('admin')
    end
  end

  describe '#managed_definitions' do
    it 'returns every authorization definition' do
      expect(authority.managed_definitions.map(&:id)).to match_array(AuthorizationDefinition.all.map(&:id))
    end
  end

  describe '#fd_manager_for?' do
    it 'returns true for any provider slug' do
      expect(authority.fd_manager_for?('dinum')).to be true
      expect(authority.fd_manager_for?('dgfip')).to be true
    end
  end

  describe '#can_manage_role?' do
    it 'returns false for the admin role' do
      expect(authority.can_manage_role?('admin')).to be false
    end

    it 'returns false for an invalid role string' do
      expect(authority.can_manage_role?('not-a-role')).to be false
    end

    it 'returns false for a role type outside allowed_role_types' do
      expect(authority.can_manage_role?('dinum:api_entreprise:something_else')).to be false
    end

    it 'returns true for a definition-level role within allowed_role_types' do
      expect(authority.can_manage_role?('dinum:api_entreprise:reporter')).to be true
    end

    it 'returns true for the developer role (admin-specific)' do
      expect(authority.can_manage_role?('dinum:api_entreprise:developer')).to be true
    end

    it 'returns true for an FD-level role' do
      expect(authority.can_manage_role?('dinum:*:manager')).to be true
    end

    context 'when the underlying user is not admin (impersonation regression guard)' do
      let(:user) { create(:user, roles: ['dinum:api_entreprise:reporter']) }

      it 'still returns true (capability does not depend on user roles)' do
        expect(authority.can_manage_role?('dgfip:api_ficoba:instructor')).to be true
      end
    end
  end

  describe '#covers_role?' do
    it 'returns false for the admin role' do
      expect(authority.covers_role?('admin')).to be false
    end

    it 'returns true for any non-admin role (regardless of role_type)' do
      expect(authority.covers_role?('dinum:api_entreprise:developer')).to be true
      expect(authority.covers_role?('dinum:api_entreprise:reporter')).to be true
    end
  end

  describe '#authorized_scopes' do
    it 'includes a fd-wildcard scope for every provider' do
      provider_slugs = AuthorizationDefinition.all.filter_map(&:provider_slug).uniq
      provider_slugs.each do |slug|
        expect(authority.authorized_scopes).to include("#{slug}:*")
      end
    end

    it 'includes every definition scope' do
      AuthorizationDefinition.all.each do |definition|
        expect(authority.authorized_scopes).to include("#{definition.provider_slug}:#{definition.id}")
      end
    end
  end
end
