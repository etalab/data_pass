require 'rails_helper'

RSpec.describe DashboardHabilitationsFacade, type: :facade do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:params) { { search_query: {} } }
  let(:scope) { Authorization.all }
  let(:search_object) do
    Search::DashboardHabilitationsSearch.new(
      user: user,
      params: params,
      scope: scope
    )
  end
  let(:facade) { described_class.new(search_object: search_object) }

  before do
    user.update!(current_organization: organization)
  end

  describe '#initialize' do
    it 'inherits from DashboardFacade' do
      expect(facade).to be_a(DashboardFacade)
    end

    it 'builds facade with unified interface' do
      expect(facade.tabs).to be_present
      expect(facade.items).to be_a(ActiveRecord::Relation)
      expect(facade.search_engine).to be_present
      expect(facade.partial).to be_present
    end
  end

  describe '#categories' do
    it 'returns habilitations categories' do
      categories = facade.categories
      
      expect(categories).to have_key(:active)
      expect(categories).to have_key(:revoked)
    end
  end

  describe '#highlighted_categories' do
    it 'returns empty highlighted categories for habilitations' do
      highlighted = facade.highlighted_categories
      
      expect(highlighted).to be_empty
    end
  end

  describe '#tabs' do
    it 'builds tabs with counts' do
      tabs = facade.tabs
      
      expect(tabs.size).to eq(2)
      expect(tabs.first.id).to eq('demandes')
      expect(tabs.last.id).to eq('habilitations')
      expect(tabs.first.count).to be_a(Integer)
      expect(tabs.last.count).to be_a(Integer)
    end
  end

  describe '#partial' do
    it 'returns the correct partial name' do
      expect(facade.partial).to eq('authorizations')
    end
  end
end
