require 'rails_helper'

RSpec.describe Instruction::Search::DashboardDemandesSearch do
  let(:user) { create(:user) }
  let(:params) { { search_query: {} } }
  let!(:authorization_request) { create(:authorization_request) }
  let(:scope) { AuthorizationRequest.all }

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
      expect(search.send(:default_sort)).to eq 'last_submitted_at desc'
    end
  end
end
