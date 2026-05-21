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

      it 'returns true for D-prefixed IDs' do
        params = { search_query: { described_class.key => 'D123' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end

      it 'returns true for H-prefixed IDs' do
        params = { search_query: { described_class.key => 'H456' } }
        expect(described_class.search_terms_is_a_possible_id?(params)).to be true
      end

      it 'returns true for lowercase prefixed IDs' do
        params = { search_query: { described_class.key => 'd789' } }
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

  describe '.extract_id_from_search_terms' do
    context 'when search input is a raw numeric ID' do
      let(:params) { { search_query: { described_class.key => '123' } } }

      it 'returns the integer for the demandes prefix' do
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'D')).to eq 123
      end

      it 'returns the integer for the habilitations prefix' do
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'H')).to eq 123
      end
    end

    context 'when search input matches the expected prefix' do
      let(:params) { { search_query: { described_class.key => 'D456' } } }

      it 'returns the integer' do
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'D')).to eq 456
      end

      it 'accepts the lowercase prefix' do
        params = { search_query: { described_class.key => 'd789' } }
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'D')).to eq 789
      end

      it 'accepts whitespace around the input' do
        params = { search_query: { described_class.key => '  H42  ' } }
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'H')).to eq 42
      end
    end

    context 'when search input has a non-matching prefix' do
      let(:params) { { search_query: { described_class.key => 'H456' } } }

      it 'returns nil' do
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'D')).to be_nil
      end
    end

    context 'when search input is not a possible ID' do
      let(:params) { { search_query: { described_class.key => 'some text' } } }

      it 'returns nil' do
        expect(described_class.extract_id_from_search_terms(params, expected_prefix: 'D')).to be_nil
      end
    end
  end
end
