RSpec.describe StatsController do
  describe 'GET #index' do
    it 'returns success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #data' do
    let(:valid_params) do
      {
        start_date: '2025-01-01',
        end_date: '2025-12-31'
      }
    end

    it 'returns JSON data' do
      get :data, params: valid_params, format: :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/json; charset=utf-8')

      json = response.parsed_body
      expect(json).to have_key('volume')
      expect(json).to have_key('durations')
      expect(json).to have_key('breakdowns')
    end

    context 'with invalid date format' do
      let(:invalid_params) { { start_date: 'invalid' } }

      it 'returns bad request' do
        get :data, params: invalid_params, format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json).to have_key('error')
      end
    end

    context 'with filter parameters' do
      let(:params_with_filters) do
        {
          start_date: '2025-01-01',
          end_date: '2025-12-31',
          providers: ['dgfip'],
          authorization_types: ['AuthorizationRequest::APIEntreprise']
        }
      end

      it 'accepts filter parameters' do
        get :data, params: params_with_filters, format: :json

        expect(response).to have_http_status(:success)
      end
    end

    context 'without date parameters' do
      it 'uses default dates (last year)' do
        get :data, format: :json

        expect(response).to have_http_status(:success)
      end
    end
  end
end
