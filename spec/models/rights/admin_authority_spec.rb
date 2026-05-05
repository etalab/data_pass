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
