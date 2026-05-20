require 'rails_helper'

RSpec.describe Instruction::UserRightsView do
  describe '#grouped_visible' do
    subject(:result) { described_class.new(authority: Rights::ManagerAuthority.new(manager), user: target).grouped_visible }

    context 'when the manager is definition-level only' do
      let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) do
        create(:user, roles: %w[dinum:api_entreprise:reporter dinum:api_entreprise:instructor dinum:api_particulier:reporter])
      end

      it 'keeps only the roles on managed definitions, grouped per scope' do
        expect(result.size).to eq(1)
        expect(result.first[:scope]).to eq('dinum:api_entreprise')
        expect(result.first[:label]).to eq(AuthorizationDefinition.find('api_entreprise').name)
        expect(result.first[:role_types]).to contain_exactly('reporter', 'instructor')
      end
    end

    context 'when the manager is FD-level and target has both wildcard and specific roles' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }
      let(:target) do
        create(:user, roles: %w[dinum:*:reporter dinum:api_entreprise:instructor])
      end

      it 'returns two separate entries, one per scope, sorted by label' do
        expect(result.pluck(:scope)).to contain_exactly('dinum:*', 'dinum:api_entreprise')
      end
    end

    context 'when the target has an admin role' do
      let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) { create(:user, :admin) }

      it 'skips admin roles' do
        expect(result).to eq([])
      end
    end
  end

  describe '#grouped_visible (admin authority)' do
    subject(:result) { described_class.new(authority: Rights::AdminAuthority.new(admin), user: target).grouped_visible }

    let(:admin) { create(:user, :admin) }

    context 'when target has only the admin role' do
      let(:target) { create(:user, :admin) }

      it 'returns a single entry with nil scope and admin role_type' do
        expect(result.size).to eq(1)
        expect(result.first[:scope]).to be_nil
        expect(result.first[:role_types]).to eq(['admin'])
      end
    end

    context 'when target has both admin and a non-admin role' do
      let(:target) { create(:user, roles: %w[admin dinum:api_entreprise:reporter]) }

      it 'returns one entry per scope (including the nil scope for admin)' do
        expect(result.pluck(:scope)).to contain_exactly(nil, 'dinum:api_entreprise')
      end
    end
  end

  describe '#readonly (admin authority)' do
    subject(:result) { described_class.new(authority: Rights::AdminAuthority.new(admin), user: target).readonly }

    let(:admin) { create(:user, :admin) }

    context 'when target has the admin role' do
      let(:target) { create(:user, roles: %w[admin dinum:api_entreprise:reporter]) }

      it 'contains the admin role as readonly (nil scope)' do
        expect(result).to contain_exactly(scope: nil, role_type: 'admin')
      end
    end
  end
end
