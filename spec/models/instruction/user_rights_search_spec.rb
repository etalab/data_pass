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
end
