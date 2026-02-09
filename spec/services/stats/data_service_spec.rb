RSpec.describe Stats::DataService do
  let(:date_range) { 1.month.ago.to_date..Date.current }

  describe '#call' do
    subject(:service) { described_class.new(date_range: date_range) }

    it 'does not include breakdowns, dimension, or filters in the result' do
      result = service.call

      expect(result).not_to have_key(:breakdowns)
      expect(result).not_to have_key(:dimension)
      expect(result).not_to have_key(:filters)
    end

    it 'includes volume data' do
      result = service.call

      expect(result).to have_key(:volume)
    end

    it 'includes durations data' do
      result = service.call

      expect(result).to have_key(:durations)
    end

    it 'includes time_series data with backlog evolution' do
      result = service.call

      expect(result).to have_key(:time_series)
      expect(result[:time_series]).to be_a(Hash)
      expect(result[:time_series]).to have_key(:unit)
      expect(result[:time_series]).to have_key(:data)
    end

    it 'includes backlog data in time_series' do
      result = service.call

      expect(result[:time_series][:data]).to all(
        have_key(:backlog)
          .and(have_key(:new_requests))
          .and(have_key(:reopenings))
          .and(have_key(:validations))
          .and(have_key(:refusals))
      )
    end
  end
end
