RSpec.describe Stats::FetchStatsData do
  let(:date_range) { 1.month.ago.to_date..Date.current }

  describe '.call' do
    subject(:result) do
      result_context = described_class.call(
        date_range: date_range,
        providers: nil,
        authorization_types: nil,
        forms: nil
      )
      {
        volume: result_context.volume,
        time_series: result_context.time_series,
        durations: result_context.durations
      }
    end

    it 'does not include breakdowns, dimension, or filters in the result' do
      expect(result).not_to have_key(:breakdowns)
      expect(result).not_to have_key(:dimension)
      expect(result).not_to have_key(:filters)
    end

    it 'includes volume data' do
      expect(result).to have_key(:volume)
    end

    it 'includes durations data' do
      expect(result).to have_key(:durations)
    end

    it 'includes time_series data with backlog evolution' do
      expect(result).to have_key(:time_series)
      expect(result[:time_series]).to be_a(Hash)
      expect(result[:time_series]).to have_key(:unit)
      expect(result[:time_series]).to have_key(:data)
    end

    it 'includes backlog data in time_series' do
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
