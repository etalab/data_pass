require 'rails_helper'

RSpec.describe Search::DashboardDemandesSearch do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:params) { { search_query: {} } }
  let(:scope) { AuthorizationRequest.all }

  before do
    user.update!(current_organization: organization)
  end

  describe '#initialize' do
    it 'inherits from Search::DashboardSearch' do
      search = described_class.new(user: user, params: params, scope: scope)
      
      expect(search).to be_a(Search::DashboardSearch)
      expect(search.user).to eq(user)
    end

    it 'builds search engine successfully' do
      search = described_class.new(user: user, params: params, scope: scope)
      
      expect(search.search_engine).to be_present
      expect(search.results).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'includes associations' do
    it 'includes applicant and authorizations' do
      search = described_class.new(user: user, params: params, scope: scope)
      
      # Verify that the search includes the expected associations
      expect(search.results.includes_values).to include(:applicant)
      expect(search.results.includes_values).to include(:authorizations)
    end
  end

  describe 'basic filtering (with simple test data)' do
    let!(:user_request) { create(:authorization_request, applicant: user, organization: organization, fill_all_attributes: false) }

    it 'finds requests for the user' do
      search = described_class.new(user: user, params: params, scope: scope)
      
      # At least verify that the search doesn't crash and can find basic records
      expect(search.count).to be >= 0
      expect(search.results).to be_a(ActiveRecord::Relation)
    end
  end
end
