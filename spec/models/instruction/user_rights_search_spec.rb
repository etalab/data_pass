require 'rails_helper'

RSpec.describe Instruction::UserRightsSearch do
  let(:alice) { create(:user, email: 'alice@gouv.fr', given_name: 'Alice', family_name: 'Martin') }
  let(:bob) { create(:user, email: 'bob@gouv.fr', given_name: 'Bob', family_name: 'Durand') }
  let(:outsider) { create(:user, email: 'outsider@gouv.fr') }
  let(:scope) { User.where(id: [alice.id, bob.id]) }

  def search(params)
    described_class.new(scope: scope, params: ActionController::Parameters.new(params))
  end

  describe '#term' do
    it 'strips surrounding whitespace' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: '  alice  ' }).term).to eq('alice')
    end

    it 'is nil when the search query is absent' do
      expect(search({}).term).to be_nil
    end

    it 'is nil when the search term is blank or whitespace-only' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: '   ' }).term).to be_nil
    end

    it 'is nil when a crafted param sends an array instead of a string' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: ['x'] }).term).to be_nil
    end

    it 'is nil when a crafted param sends a nested hash instead of a string' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: { nested: 'x' } }).term).to be_nil
    end
  end

  describe '#results' do
    before { outsider }

    it 'returns the whole scope when no search query is given' do
      expect(search({}).results).to contain_exactly(alice, bob)
    end

    it 'returns the whole scope when the search term is blank' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: '   ' }).results).to contain_exactly(alice, bob)
    end

    it 'never returns records outside the given scope on a blank search' do
      expect(search({}).results).not_to include(outsider)
    end

    it 'returns the whole scope without raising when a crafted param sends an array' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: ['x'] }).results).to contain_exactly(alice, bob)
    end

    it 'filters by email, given name or family name when a term is present' do
      expect(search(search_query: { email_or_given_name_or_family_name_cont: 'alice' }).results).to contain_exactly(alice)
    end

    it 'orders results by email' do
      expect(search({}).results.to_a).to eq([alice, bob])
    end
  end

  describe 'filtering by role type and rights' do
    let(:manager_entreprise) { create(:user, email: 'a@gouv.fr', roles: %w[dinum:api_entreprise:manager]) }
    let(:instructor_particulier) { create(:user, email: 'b@gouv.fr', roles: %w[dinum:api_particulier:instructor]) }
    let(:developer_entreprise) { create(:user, email: 'c@gouv.fr', roles: %w[dinum:api_entreprise:developer]) }
    let(:fd_manager) { create(:user, email: 'd@gouv.fr', roles: %w[dinum:*:manager]) }
    let(:admin_user) { create(:user, email: 'e@gouv.fr', roles: %w[admin]) }
    let(:scope) do
      User.where(id: [manager_entreprise, instructor_particulier, developer_entreprise, fd_manager, admin_user].map(&:id))
    end

    context 'when filtering by role type' do
      it 'matches literal holders of that role, specific and FD-level' do
        expect(search(filters: { role: 'manager' }).results).to contain_exactly(manager_entreprise, fd_manager)
      end

      it 'does not include a developer when filtering on instructor' do
        expect(search(filters: { role: 'instructor' }).results).to contain_exactly(instructor_particulier)
      end

      it 'matches admins when filtering on admin' do
        expect(search(filters: { role: 'admin' }).results).to contain_exactly(admin_user)
      end
    end

    context 'when filtering by rights presence' do
      it 'keeps only users with an explicit specific-definition right on « with »' do
        expect(search(filters: { droit: 'with' }).results)
          .to contain_exactly(manager_entreprise, instructor_particulier, developer_entreprise)
      end

      it 'keeps only users without any specific right on « without »' do
        expect(search(filters: { droit: 'without' }).results).to contain_exactly(fd_manager, admin_user)
      end
    end

    context 'when filtering by a specific API' do
      it 'matches only users with an explicit right on that definition' do
        expect(search(filters: { droit: 'api_entreprise' }).results)
          .to contain_exactly(manager_entreprise, developer_entreprise)
      end
    end

    context 'when combining a role filter and an API filter' do
      it 'intersects both axes (manager AND api_entreprise)' do
        expect(search(filters: { role: 'manager', droit: 'api_entreprise' }).results)
          .to contain_exactly(manager_entreprise)
      end
    end

    context 'when a crafted param sends a filter as an array' do
      it 'ignores it and returns the whole scope' do
        expect(search(filters: { role: ['manager'] }).results).to match_array(scope)
      end
    end
  end
end
