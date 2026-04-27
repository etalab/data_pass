require 'rails_helper'

RSpec.describe UserRole do
  describe 'validations' do
    it 'is valid with a role, data_provider, and definition' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(user: create(:user), role: 'instructor', data_provider: dp, authorization_definition_id: 'api_entreprise')

      expect(user_role).to be_valid
    end

    it 'is valid as admin without data_provider' do
      user_role = described_class.new(user: create(:user), role: 'admin')

      expect(user_role).to be_valid
    end

    it 'is valid as FD-level (no authorization_definition_id)' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(user: create(:user), role: 'instructor', data_provider: dp)

      expect(user_role).to be_valid
    end

    it 'is invalid without a role' do
      user_role = described_class.new(user: create(:user), role: nil)

      expect(user_role).not_to be_valid
    end

    it 'is invalid with unknown role' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(user: create(:user), role: 'unknown', data_provider: dp)

      expect(user_role).not_to be_valid
    end

    it 'is invalid without data_provider for non-admin role' do
      user_role = described_class.new(user: create(:user), role: 'instructor')

      expect(user_role).not_to be_valid
    end

    it 'validates definition belongs to provider' do
      dp = create(:data_provider, slug: 'wrong_provider', name: 'Wrong', link: 'https://wrong.fr')
      user_role = described_class.new(user: create(:user), role: 'instructor', data_provider: dp, authorization_definition_id: 'api_entreprise')

      expect(user_role).not_to be_valid
      expect(user_role.errors[:authorization_definition_id]).to be_present
    end
  end

  describe '#sync_data_provider_slug' do
    it 'sets data_provider_slug from data_provider on validation' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(user: create(:user), role: 'instructor', data_provider: dp, authorization_definition_id: 'api_entreprise')

      user_role.valid?

      expect(user_role.data_provider_slug).to eq('dinum')
    end
  end

  describe '.effective_for_role' do
    it 'returns roles matching the hierarchy' do
      user = create(:user)
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      manager_role = described_class.create!(user: user, role: 'manager', data_provider: dp, authorization_definition_id: 'api_entreprise')
      described_class.create!(user: user, role: 'reporter', data_provider: dp, authorization_definition_id: 'api_particulier')

      result = described_class.effective_for_role(:instructor)

      expect(result).to include(manager_role)
    end
  end

  describe '.effective_for_definition' do
    it 'matches definition-level role' do
      user = create(:user)
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      role = described_class.create!(user: user, role: 'instructor', data_provider: dp, authorization_definition_id: 'api_entreprise')

      expect(described_class.effective_for_definition('api_entreprise')).to include(role)
    end

    it 'matches FD-level wildcard role' do
      user = create(:user)
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      role = described_class.create!(user: user, role: 'instructor', data_provider: dp, authorization_definition_id: nil)

      expect(described_class.effective_for_definition('api_entreprise')).to include(role)
    end

    it 'does not match role for different provider' do
      user = create(:user)
      dp = create(:data_provider, slug: 'other_provider', name: 'Other', link: 'https://other.fr')
      role = described_class.create!(user: user, role: 'instructor', data_provider: dp, authorization_definition_id: nil)

      expect(described_class.effective_for_definition('api_entreprise')).not_to include(role)
    end
  end

  describe '#covered_definition_ids' do
    it 'returns definition_id for definition-level role' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(role: 'instructor', data_provider: dp, data_provider_slug: 'dinum', authorization_definition_id: 'api_entreprise')

      expect(user_role.covered_definition_ids).to eq(['api_entreprise'])
    end

    it 'returns all definitions under provider for FD-level role' do
      dp = DataProvider.find_by(slug: 'dinum') || create(:data_provider, slug: 'dinum', name: 'DINUM', link: 'https://dinum.gouv.fr')
      user_role = described_class.new(role: 'instructor', data_provider: dp, data_provider_slug: 'dinum', authorization_definition_id: nil)

      dinum_ids = AuthorizationDefinition.all.select { |ad| ad.provider_slug == 'dinum' }.map(&:id)

      expect(user_role.covered_definition_ids).to match_array(dinum_ids)
    end
  end
end
