RSpec.describe Stats::DataService, type: :service do
  let(:date_range) { Date.new(2025, 1, 1)..Date.new(2025, 12, 31) }

  describe '#call' do
    subject(:result) { described_class.new(date_range: date_range).call }

    it 'returns a hash with expected keys' do
      expect(result).to be_a(Hash)
      expect(result).to have_key(:filters)
      expect(result).to have_key(:dimension)
      expect(result).to have_key(:volume)
      expect(result).to have_key(:durations)
      expect(result).to have_key(:breakdowns)
    end

    it 'returns volume data' do
      expect(result[:volume]).to have_key(:new_requests_submitted)
      expect(result[:volume]).to have_key(:reopenings_submitted)
      expect(result[:volume]).to have_key(:validations)
      expect(result[:volume]).to have_key(:refusals)
    end

    it 'returns durations data' do
      expect(result[:durations]).to have_key(:time_to_submit)
      expect(result[:durations]).to have_key(:time_to_first_instruction)
      expect(result[:durations]).to have_key(:time_to_final_instruction)
    end
  end

  describe '#determine_dimension' do
    it 'returns provider by default' do
      service = described_class.new(date_range: date_range)
      expect(service.send(:determine_dimension)).to eq('provider')
    end

    it 'returns type when one provider is selected' do
      service = described_class.new(date_range: date_range, providers: ['dgfip'])
      expect(service.send(:determine_dimension)).to eq('type')
    end

    it 'returns form when one type is selected' do
      service = described_class.new(
        date_range: date_range,
        authorization_types: ['AuthorizationRequest::APIEntreprise']
      )
      expect(service.send(:determine_dimension)).to eq('form')
    end
  end
end
