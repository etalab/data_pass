require 'rails_helper'

RSpec.describe Instruction::Search::DashboardHabilitationsSearch do
  let(:user) { create(:user) }
  let(:params) { { search_query: {} } }
  let!(:authorization) { create(:authorization) }
  let(:scope) { Authorization.all }

  describe '#initialize' do
    it 'creates a search object successfully' do
      search = described_class.new(params: params, scope: scope)
      expect(search).to be_an_instance_of(described_class)
      expect(search.search_engine).to be_present
      expect(search.results).to be_present
    end
  end

  describe '#default_sort' do
    it 'returns the correct default sort' do
      search = described_class.new(params: params, scope: scope)
      expect(search.send(:default_sort)).to eq 'created_at desc'
    end
  end
end
