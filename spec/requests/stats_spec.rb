require 'rails_helper'

RSpec.describe 'Stats' do
  describe 'GET /stats/data' do
    let(:start_date) { 1.month.ago.to_date }
    let(:end_date) { Date.current }

    it 'returns success' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      expect(response).to have_http_status(:success)
    end

    it 'returns JSON without breakdowns for performance' do
      get stats_data_path(start_date: start_date, end_date: end_date)

      json_response = response.parsed_body
      expect(json_response).not_to have_key('breakdowns')
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
  end
end
