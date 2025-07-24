require 'rails_helper'

RSpec.describe Search::DashboardSearch do
  describe '.search_terms_is_a_possible_id?' do
    context 'when search_query is blank' do
      it 'returns false' do
        params = { search_query: nil }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end

    context 'when main search input is blank' do
      it 'returns false' do
        params = { search_query: { 'within_data_or_id_cont' => '' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end

    context 'when main search input is a valid ID' do
      it 'returns true for numeric strings' do
        params = { search_query: { 'within_data_or_id_cont' => '123' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end

      it 'returns true for numeric strings with whitespace' do
        params = { search_query: { 'within_data_or_id_cont' => '  456  ' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end
    end

    context 'when main search input is not a valid ID' do
      it 'returns false for non-numeric strings' do
        params = { search_query: { 'within_data_or_id_cont' => 'abc' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end

      it 'returns false for mixed alphanumeric strings' do
        params = { search_query: { 'within_data_or_id_cont' => '123abc' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end
  end

  describe '#initialize' do
    let(:user) { create(:user) }
    let(:params) { { search_query: {} } }
    let(:scope) { AuthorizationRequest.all }

    it 'initializes with required parameters' do
      search = TestDashboardSearch.new(user: user, params: params, scope: scope)
      
      expect(search.user).to eq(user)
      expect(search.search_engine).to be_present
      expect(search.results).to be_a(ActiveRecord::Relation)
    end

    it 'accepts optional subdomain_types' do
      subdomain_types = ['test_type']
      search = TestDashboardSearch.new(
        user: user, 
        params: params, 
        scope: scope, 
        subdomain_types: subdomain_types
      )
      
      expect(search.subdomain_types).to eq(subdomain_types)
    end
  end

  describe '#paginated_results' do
    let(:user) { create(:user) }
    let(:params) { { search_query: {}, page: 2 } }
    let(:scope) { AuthorizationRequest.all }

    it 'returns paginated results' do
      search = TestDashboardSearch.new(user: user, params: params, scope: scope)
      
      expect(search.paginated_results).to respond_to(:current_page)
      expect(search.paginated_results.current_page).to eq(2)
    end
  end

  describe '#count' do
    let(:user) { create(:user) }
    let(:params) { { search_query: {} } }
    let(:scope) { AuthorizationRequest.all }

    it 'delegates count to results' do
      search = TestDashboardSearch.new(user: user, params: params, scope: scope)
      
      expect(search.count).to be_a(Integer)
    end
  end
end

# Test implementation of abstract class
class TestDashboardSearch < Search::DashboardSearch
  private

  def includes_associations
    [:applicant]
  end

  def filter_by_applicant
    base_relation.where(applicant: user, organization: user.current_organization)
  end

  def filter_by_contact
    authorization_request_mentions_query(base_relation).where.not(applicant: user)
  end

  def filter_by_organization
    base_relation.where(organization: user.current_organization)
  end
end
