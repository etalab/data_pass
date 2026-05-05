require 'rails_helper'

RSpec.describe Instruction::MergeManagedRoles, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(authority: Rights::ManagerAuthority.new(manager), user:, new_roles:) }

    let(:manager) { create(:user, roles: ['dinum:api_entreprise:manager']) }
    let(:user) { create(:user, roles: initial_roles) }

    context 'when user has no role yet' do
      let(:initial_roles) { [] }
      let(:new_roles) { %w[dinum:api_entreprise:reporter dinum:api_entreprise:instructor] }

      it 'assigns the new roles on the user (without saving)' do
        result

        expect(user.roles).to eq(new_roles)
        expect(user).to be_changed
      end
    end

    context 'when user has existing roles outside the manager scope' do
      let(:initial_roles) { %w[dinum:api_particulier:instructor admin] }
      let(:new_roles) { %w[dinum:api_entreprise:reporter] }

      it 'preserves out-of-scope roles and adds new ones' do
        result

        expect(user.roles).to match_array(
          %w[dinum:api_particulier:instructor admin dinum:api_entreprise:reporter]
        )
      end
    end

    context 'when user has existing roles within the manager scope' do
      let(:initial_roles) { %w[dinum:api_entreprise:reporter dinum:api_particulier:reporter] }
      let(:new_roles) { %w[dinum:api_entreprise:manager] }

      it 'replaces in-scope roles with the incoming ones' do
        result

        expect(user.roles).to match_array(%w[dinum:api_particulier:reporter dinum:api_entreprise:manager])
      end
    end

    context 'when new_roles contains a definition that the manager does not manage' do
      let(:initial_roles) { [] }
      let(:new_roles) { %w[dinum:api_entreprise:reporter dinum:api_particulier:reporter] }

      it 'keeps only roles on managed definitions' do
        result

        expect(user.roles).to eq(%w[dinum:api_entreprise:reporter])
      end
    end

    context 'when new_roles contains duplicates' do
      let(:initial_roles) { [] }
      let(:new_roles) { %w[dinum:api_entreprise:reporter dinum:api_entreprise:reporter] }

      it 'deduplicates' do
        result

        expect(user.roles).to eq(%w[dinum:api_entreprise:reporter])
      end
    end

    context 'when user has a developer role on a managed definition' do
      let(:initial_roles) { %w[dinum:api_entreprise:developer dinum:api_entreprise:reporter] }
      let(:new_roles) { %w[dinum:api_entreprise:instructor] }

      it 'preserves the developer role and replaces the other managed roles' do
        result

        expect(user.roles).to match_array(%w[dinum:api_entreprise:developer dinum:api_entreprise:instructor])
      end
    end

    context 'when destroy-like call (empty new_roles) and user has a developer role' do
      let(:initial_roles) { %w[dinum:api_entreprise:developer dinum:api_entreprise:reporter dinum:api_particulier:reporter] }
      let(:new_roles) { [] }

      it 'preserves developer and out-of-scope roles and drops the other managed roles' do
        result

        expect(user.roles).to match_array(%w[dinum:api_entreprise:developer dinum:api_particulier:reporter])
      end
    end

    it 'does not persist the user' do
      user = create(:user, roles: [])
      described_class.call(authority: Rights::ManagerAuthority.new(manager), user:, new_roles: %w[dinum:api_entreprise:reporter])

      expect(user.reload.roles).to eq([])
    end

    context 'when the manager is an FD-level manager' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }

      context 'when new_roles mixes wildcard and definition roles' do
        let(:initial_roles) { [] }
        let(:new_roles) { %w[dinum:*:reporter dinum:api_entreprise:instructor] }

        it 'applies both' do
          result

          expect(user.roles).to match_array(%w[dinum:*:reporter dinum:api_entreprise:instructor])
        end
      end

      context 'when the user already had an FD-wildcard role on another FD' do
        let(:initial_roles) { %w[dgfip:*:reporter] }
        let(:new_roles) { %w[dinum:*:manager] }

        it 'preserves the out-of-scope FD-wildcard' do
          result

          expect(user.roles).to match_array(%w[dgfip:*:reporter dinum:*:manager])
        end
      end
    end

    context 'when a definition-level manager tries to push an FD-wildcard role' do
      let(:initial_roles) { [] }
      let(:new_roles) { %w[dinum:*:reporter] }

      it 'drops it because the manager cannot cover FD-wildcards' do
        result

        expect(user.roles).to eq([])
      end
    end

    context 'when the user has an FD-wildcard role and the manager is FD-level' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }
      let(:initial_roles) { %w[dinum:*:reporter] }
      let(:new_roles) { [] }

      it 'drops the modifiable FD-wildcard role on destroy-like call' do
        result

        expect(user.roles).to eq([])
      end
    end

    context 'when the user has an FD-wildcard role and the manager is only definition-level' do
      let(:initial_roles) { %w[dinum:*:reporter] }
      let(:new_roles) { [] }

      it 'preserves the FD-wildcard role (out of manager authority)' do
        result

        expect(user.roles).to eq(%w[dinum:*:reporter])
      end
    end
  end
end
