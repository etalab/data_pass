require 'rails_helper'

RSpec.describe RoleHierarchy do
  describe '.qualifying_roles' do
    it 'returns reporter plus all roles that imply reporter' do
      expect(described_class.qualifying_roles(:reporter)).to match_array(%w[reporter manager instructor developer])
    end

    it 'returns instructor plus manager' do
      expect(described_class.qualifying_roles(:instructor)).to match_array(%w[instructor manager])
    end

    it 'returns only manager for manager' do
      expect(described_class.qualifying_roles(:manager)).to eq(%w[manager])
    end

    it 'returns only developer for developer' do
      expect(described_class.qualifying_roles(:developer)).to eq(%w[developer])
    end

    it 'accepts string arguments' do
      expect(described_class.qualifying_roles('instructor')).to match_array(%w[instructor manager])
    end
  end
end
