RSpec.describe 'Stats' do
  describe 'GET /stats/filters' do
    it 'returns success' do
      get stats_filters_path

      expect(response).to have_http_status(:success)
    end

    it 'returns providers list' do
      get stats_filters_path

      json_response = response.parsed_body
      expect(json_response).to have_key('providers')
      expect(json_response['providers']).to be_an(Array)
    end

    it 'returns types list' do
      get stats_filters_path

      json_response = response.parsed_body
      expect(json_response).to have_key('types')
      expect(json_response['types']).to be_an(Array)
    end
  end

  describe 'GET /stats/data' do
    let(:start_date) { 1.month.ago.to_date }
    let(:end_date) { Date.current }

    it 'returns success' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      expect(response).to have_http_status(:success)
    end

    it 'returns volume data' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      json_response = response.parsed_body
      expect(json_response).to have_key('volume')
    end

    it 'returns durations data' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      json_response = response.parsed_body
      expect(json_response).to have_key('durations')
    end

    it 'returns time_series data' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      json_response = response.parsed_body
      expect(json_response).to have_key('time_series')
    end

    it 'returns bad request for invalid date format' do
      get stats_data_path(start_date: 'not-a-date', end_date: end_date)

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to have_key('error')
    end

    it 'returns bad request when start date is after end date' do
      get stats_data_path(start_date: end_date, end_date: start_date)

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['error']).to eq(I18n.t('stats.errors.start_before_end'))
    end
  end
end
