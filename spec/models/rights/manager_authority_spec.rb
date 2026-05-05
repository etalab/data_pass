require 'rails_helper'

RSpec.describe Rights::ManagerAuthority do
  subject(:authority) { described_class.new(user) }

  describe '#allowed_role_types' do
    let(:user) { create(:user) }

    it 'returns reporter, instructor and manager' do
      expect(authority.allowed_role_types).to eq(%w[reporter instructor manager])
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

  describe '#authorized_scopes' do
    context 'when the user is FD-manager and definition-manager' do
      let(:user) { create(:user, roles: ['dinum:*:manager', 'dgfip:api_ficoba:manager']) }

      it 'includes both fd-wildcard scopes and definition scopes' do
        expect(authority.authorized_scopes).to include('dinum:*', 'dgfip:api_ficoba')
      end
    end
  end
end
