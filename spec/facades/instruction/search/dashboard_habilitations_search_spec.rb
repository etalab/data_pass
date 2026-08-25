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

  describe 'ID search' do
    let(:search_key) { described_class.key }

    context 'with an exact numeric ID' do
      let(:params) { { search_query: { search_key => authorization.id.to_s } } }

      it 'returns the matching authorization' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization)
      end
    end

    context 'with a partial numeric ID' do
      let!(:authorization) { create(:authorization, id: 12_345) }
      let(:params) { { search_query: { search_key => '123' } } }

      it 'returns authorizations whose ID starts with the partial input' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization)
      end
    end

    context 'with a partial ID that is not a prefix of the record ID' do
      let!(:authorization) { create(:authorization, id: 12_345) }
      let(:params) { { search_query: { search_key => '234' } } }

      it 'does not return the record' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).not_to include(authorization)
      end
    end

    context 'with an H-prefixed ID' do
      let(:params) { { search_query: { search_key => "H#{authorization.id}" } } }

      it 'returns the matching authorization' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization)
      end
    end

    context 'with a D-prefixed ID' do
      let(:params) { { search_query: { search_key => "D#{authorization.id}" } } }

      it 'returns no results' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to be_empty
      end
    end
  end

  describe 'sorting' do
    let(:default_order_clause) { 'ORDER BY "authorizations"."created_at" DESC NULLS LAST' }

    context 'with a malicious sort injected in the query' do
      let(:params) { { search_query: { 's' => %q{'"()&%<zzz><ScRiPt asc} } } }

      it 'leaves no injected fragment in the generated SQL and falls back to the default sort' do
        search = described_class.new(params: params, scope: scope)

        expect(search.results.to_sql).not_to include('ScRiPt')
        expect(search.results.to_sql).to include(default_order_clause)
        expect(search.results).to include(authorization)
      end
    end

    context 'with a sort on a non-existent column' do
      let(:params) { { search_query: { 's' => 'evil_column asc' } } }

      it 'falls back to the default sort' do
        search = described_class.new(params: params, scope: scope)

        expect(search.results.to_sql).not_to include('evil_column')
        expect(search.results.to_sql).to include(default_order_clause)
      end
    end

    context 'with a legitimate column sort' do
      let(:params) { { search_query: { 's' => 'created_at asc' } } }

      it 'orders by the requested column with a quoted identifier' do
        search = described_class.new(params: params, scope: scope)

        expect(search.results.to_sql).to include('ORDER BY "authorizations"."created_at" ASC NULLS LAST')
        expect(search.results).to include(authorization)
      end
    end
  end
end
