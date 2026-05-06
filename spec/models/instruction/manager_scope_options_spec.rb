require 'rails_helper'

RSpec.describe Instruction::ManagerScopeOptions do
  describe '#managed_definitions' do
    it 'returns the authorization definitions the manager manages' do
      manager = create(:user, roles: ['dinum:api_entreprise:manager'])

      options = described_class.new(manager)

      expect(options.managed_definitions.map(&:id)).to eq(['api_entreprise'])
    end
  end

  describe '#authorized_scopes' do
    context 'when the manager is definition-level' do
      it 'lists only definition scopes' do
        manager = create(:user, roles: ['dinum:api_entreprise:manager'])

        options = described_class.new(manager)

        expect(options.authorized_scopes).to contain_exactly('dinum:api_entreprise')
      end
    end

    context 'when the manager is FD-level' do
      it 'lists both the FD-wildcard scope and each definition scope' do
        manager = create(:user, roles: ['dinum:*:manager'])

        options = described_class.new(manager)

        expect(options.authorized_scopes).to include('dinum:*', 'dinum:api_entreprise')
      end
    end
  end
end
