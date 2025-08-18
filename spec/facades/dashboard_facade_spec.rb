RSpec.describe DashboardFacade, type: :facade do
  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, current_organization: organization) }

  describe 'legacy initialization pattern' do
    let(:facade) { described_class.new(current_user, nil, subdomain_types: nil) }

    before do
      current_user.current_organization = organization
    end

    it 'initializes with user parameters for backward compatibility' do
      expect(facade.instance_variable_get(:@user)).to eq(current_user)
    end

    it 'returns nil for new interface methods when no search object' do
      expect(facade.categories).to be_nil
      expect(facade.highlighted_categories).to be_nil
    end
  end

  describe 'Tab data structure' do
    it 'defines Tab as a data class with id, path, and count' do
      tab = DashboardFacade::Tab.new('test', '/path', 5)
      expect(tab.id).to eq('test')
      expect(tab.path).to eq('/path')
      expect(tab.count).to eq(5)
    end
  end
end
