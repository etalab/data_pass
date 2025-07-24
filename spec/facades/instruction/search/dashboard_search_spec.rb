require 'rails_helper'

RSpec.describe Instruction::Search::DashboardSearch do
  describe '.search_terms_is_a_possible_id?' do
    context 'when search_query is blank' do
      it 'returns false' do
        params = { search_query: nil }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end

    context 'when main search input is blank' do
      it 'returns false' do
        params = { search_query: { described_class.key => '' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end

    context 'when main search input is a valid ID' do
      it 'returns true for numeric strings' do
        params = { search_query: { described_class.key => '123' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end

      it 'returns true for numeric strings with whitespace' do
        params = { search_query: { described_class.key => '  456  ' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end
    end

    context 'when main search input is not a valid ID' do
      it 'returns false for text' do
        params = { search_query: { described_class.key => 'some text' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end

      it 'returns false for mixed alphanumeric' do
        params = { search_query: { described_class.key => 'abc123' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be false
      end
    end
  end

  describe '.key' do
    it 'returns the correct search input key' do
      expected_key = 'within_data_or_organization_name_or_organization_legal_entity_id_or_applicant_email_or_applicant_family_name_cont'
      expect(described_class.key).to eq expected_key
    end
  end
end
