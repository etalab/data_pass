require 'rails_helper'

RSpec.describe AuthorizationRequestStatsController do
  describe 'GET #processing_time' do
    let(:processing_days) { 13 }
    let(:authorization_request_class) { 'AuthorizationRequest::APIEntreprise' }
    let(:cache_key) { "processing_days_#{authorization_request_class}" }
    let(:query_instance) { instance_double(ProcessingTimeQuery) }

    before do
      Rails.cache.clear

      allow(ProcessingTimeQuery).to receive(:new).with(authorization_request_class).and_return(query_instance)
    end

    context 'when the query succeeds' do
      before do
        allow(query_instance).to receive(:perform).and_return(processing_days)

        get :processing_time, params: { definition: 'api_entreprise' }
      end

      it 'renders the correct processing time in a turbo frame' do
        expect(response.body).to include("<turbo-frame id='processing-time'>~#{processing_days} jours</turbo-frame>")
      end
    end

    context 'when caching' do
      it 'caches the processing time for a week' do
        expect(Rails.cache).to receive(:fetch).with(cache_key, expires_in: 1.week).and_yield

        allow(query_instance).to receive(:perform).and_return(processing_days)

        get :processing_time, params: { definition: 'api_entreprise' }
      end

      it 'returns cached result on subsequent calls' do
        Rails.cache.write(cache_key, processing_days, expires_in: 1.week)

        expect(ProcessingTimeQuery).not_to receive(:new)
        get :processing_time, params: { definition: 'api_entreprise' }

        expect(response.body).to include("<turbo-frame id='processing-time'>~#{processing_days} jours</turbo-frame>")
      end
    end

    context 'when an error occurs' do
      before do
        allow(query_instance).to receive(:perform).and_raise(StandardError)
      end

      it 'renders the fallback message with a default value' do
        get :processing_time, params: { definition: 'api_entreprise' }

        expect(response.body).to include("<turbo-frame id='processing-time'>~11 jours (estimation historique)</turbo-frame>")
      end
    end
  end
end
