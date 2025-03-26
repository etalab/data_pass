class AuthorizationRequestStatsController < ApplicationController
  def processing_time
    authorization_request_class = AuthorizationDefinition.find(params[:definition]).authorization_request_class.to_s

    processing_days = fetch_processing_days_from_db_or_cache(authorization_request_class)

    render plain: "<turbo-frame id='processing-time'>~#{processing_days} jours</turbo-frame>", content_type: 'text/html'
  rescue StandardError
    render plain: "<turbo-frame id='processing-time'>~11 jours (estimation historique)</turbo-frame>", content_type: 'text/html'
  end

  private

  def fetch_processing_days_from_db_or_cache(authorization_request_class)
    cache_key = "processing_days_#{authorization_request_class}"

    Rails.cache.fetch(cache_key, expires_in: 1.week) { ProcessingTimeQuery.new(authorization_request_class).perform }
  end
end
