RSpec.describe Stats::TimeSeriesQuery do
  let(:start_date) { Date.new(2024, 1, 1) }
  let(:end_date) { Date.new(2024, 1, 31) }
  let(:date_range) { start_date..end_date }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, created_at: start_date + 5.days) }

  before do
    create(:authorization_request_event, :create,
      authorization_request: authorization_request,
      created_at: start_date + 5.days)
    create(:authorization_request_event, :submit,
      authorization_request: authorization_request,
      created_at: start_date + 5.days)
  end

  describe '#time_series_data' do
    subject(:query) { described_class.new(date_range: date_range) }

    it 'returns time series data with unit and data' do
      result = query.time_series_data

      expect(result).to have_key(:unit)
      expect(result).to have_key(:data)
      expect(result[:data]).to be_an(Array)
    end

    it 'includes new_requests, reopenings, validations, and refusals in each data point' do
      result = query.time_series_data

      expect(result[:data]).to all(have_key(:period)
        .and(have_key(:new_requests))
        .and(have_key(:reopenings))
        .and(have_key(:validations))
        .and(have_key(:refusals)))
    end

    context 'with date range of 30 days or less' do
      let(:start_date) { Date.new(2024, 1, 1) }
      let(:end_date) { Date.new(2024, 1, 31) }

      it 'uses day as time unit' do
        result = query.time_series_data

        expect(result[:unit]).to eq('day')
      end
    end

    context 'with date range between 31 and 183 days' do
      let(:start_date) { Date.new(2024, 1, 1) }
      let(:end_date) { Date.new(2024, 6, 30) }

      it 'uses week as time unit' do
        result = query.time_series_data

        expect(result[:unit]).to eq('week')
      end
    end

    context 'with date range between 183 days and 2 years' do
      let(:start_date) { Date.new(2024, 1, 1) }
      let(:end_date) { Date.new(2024, 12, 31) }

      it 'uses month as time unit' do
        result = query.time_series_data

        expect(result[:unit]).to eq('month')
      end
    end

    context 'with date range over 2 years' do
      let(:start_date) { Date.new(2022, 1, 1) }
      let(:end_date) { Date.new(2024, 12, 31) }

      it 'uses year as time unit' do
        result = query.time_series_data

        expect(result[:unit]).to eq('year')
      end
    end

    context 'with new requests and validations' do
      let(:authorization_request_2) { create(:authorization_request, :api_entreprise, created_at: start_date + 15.days) }

      before do
        create(:authorization_request_event, :create,
          authorization_request: authorization_request_2,
          created_at: start_date + 15.days)
        create(:authorization_request_event, :submit,
          authorization_request: authorization_request_2,
          created_at: start_date + 15.days)

        create(:authorization_request_event, :approve,
          authorization_request: authorization_request,
          created_at: start_date + 10.days)
      end

      it 'counts new requests and validations correctly' do
        result = query.time_series_data

        total_new_requests = result[:data].sum { |d| d[:new_requests] }
        total_validations = result[:data].sum { |d| d[:validations] }

        expect(total_new_requests).to eq(2)
        expect(total_validations).to eq(1)
      end
    end

    context 'with reopenings and refusals' do
      before do
        create(:authorization_request_event, :refuse,
          authorization_request: authorization_request,
          created_at: start_date + 8.days)

        create(:authorization_request_event, :reopen,
          authorization_request: authorization_request,
          created_at: start_date + 12.days)

        create(:authorization_request_event, :submit,
          authorization_request: authorization_request,
          created_at: start_date + 13.days)
      end

      it 'counts reopenings and refusals correctly' do
        result = query.time_series_data

        total_reopenings = result[:data].sum { |d| d[:reopenings] }
        total_refusals = result[:data].sum { |d| d[:refusals] }

        expect(total_reopenings).to eq(1)
        expect(total_refusals).to eq(1)
      end
    end
  end
end
