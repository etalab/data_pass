require 'rails_helper'

RSpec.describe Instruction::DashboardHabilitationsFacade do
  let(:user) { create(:user) }
  let(:params) { { search_query: {} } }
  let!(:authorization) { create(:authorization) }
  let(:scope) { Authorization.all }
  let(:search_object) { Instruction::Search::DashboardHabilitationsSearch.new(params: params, scope: scope) }
  let(:facade) { described_class.new(search_object: search_object) }

  describe '#initialize' do
    it 'creates a facade successfully' do
      expect(facade).to be_an_instance_of(described_class)
      expect(facade.tabs).to be_present
      expect(facade.items).to be_present
      expect(facade.search_engine).to be_present
      expect(facade.partial).to eq 'authorizations'
    end
  end

  describe '#partial_name' do
    it 'returns the correct partial name' do
      expect(facade.send(:partial_name)).to eq 'authorizations'
    end
  end

  describe '#demandes_count' do
    it 'returns 0' do
      expect(facade.send(:demandes_count)).to eq 0
    end
  end

  describe '#habilitations_count' do
    it 'returns the search object count' do
      expect(facade.send(:habilitations_count)).to eq search_object.count
    end
  end
end
