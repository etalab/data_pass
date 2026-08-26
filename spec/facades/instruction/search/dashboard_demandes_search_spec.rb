require 'rails_helper'

RSpec.describe Instruction::Search::DashboardDemandesSearch do
  let(:user) { create(:user) }
  let(:params) { { search_query: {} } }
  let!(:authorization_request) { create(:authorization_request) }
  let(:scope) { AuthorizationRequest.all }
  let(:search_key) { described_class.key }

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

  describe 'ID search' do
    context 'with an exact numeric ID' do
      let(:params) { { search_query: { search_key => authorization_request.id.to_s } } }

      it 'returns the matching request' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization_request)
      end
    end

    context 'with a partial numeric ID' do
      let!(:authorization_request) { create(:authorization_request, id: 12_345) }
      let(:params) { { search_query: { search_key => '123' } } }

      it 'returns requests whose ID starts with the partial input' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization_request)
      end
    end

    context 'with a partial ID that is not a prefix of the record ID' do
      let!(:authorization_request) { create(:authorization_request, id: 12_345) }
      let(:params) { { search_query: { search_key => '234' } } }

      it 'does not return the record' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).not_to include(authorization_request)
      end
    end

    context 'with a D-prefixed ID' do
      let(:params) { { search_query: { search_key => "D#{authorization_request.id}" } } }

      it 'returns the matching request' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(authorization_request)
      end
    end

    context 'with an H-prefixed ID' do
      let(:params) { { search_query: { search_key => "H#{authorization_request.id}" } } }

      it 'returns no results' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to be_empty
      end
    end

    context 'with a validated demande' do
      let!(:validated_request) { create(:authorization_request, :validated) }
      let(:params) { { search_query: { search_key => validated_request.id.to_s } } }

      it 'returns the validated request' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(validated_request)
      end
    end

    context 'with an archived demande' do
      let!(:archived_request) { create(:authorization_request, :archived) }
      let(:params) { { search_query: { search_key => archived_request.id.to_s } } }

      it 'returns the archived request' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).to include(archived_request)
      end
    end
  end

  describe 'non-ID search' do
    context 'with a validated demande' do
      let!(:validated_request) { create(:authorization_request, :validated) }
      let(:params) { { search_query: { search_key => validated_request.organization.siret } } }

      it 'does not return the validated request' do
        search = described_class.new(params: params, scope: scope)
        expect(search.results).not_to include(validated_request)
      end
    end
  end

  describe 'sorting' do
    let(:default_order_clause) { 'ORDER BY "authorization_requests"."last_submitted_at" DESC NULLS LAST' }

    context 'with a malicious sort injected in the query' do
      let(:params) { { search_query: { 's' => %q{'"()&%<zzz><ScRiPt asc} } } }

      it 'leaves no injected fragment in the generated SQL and falls back to the default sort' do
        search = described_class.new(params: params, scope: scope)

        expect(search.results.to_sql).not_to include('ScRiPt')
        expect(search.results.to_sql).to include(default_order_clause)
        expect(search.results).to include(authorization_request)
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
      let(:params) { { search_query: { 's' => 'last_submitted_at asc' } } }

      it 'orders by the requested column with a quoted identifier' do
        search = described_class.new(params: params, scope: scope)

        expect(search.results.to_sql).to include('ORDER BY "authorization_requests"."last_submitted_at" ASC NULLS LAST')
        expect(search.results).to include(authorization_request)
      end
    end
  end
end
