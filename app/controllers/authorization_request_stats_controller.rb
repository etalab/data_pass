class AuthorizationRequestStatsController < ApplicationController
  DEFAULT_PROCESSING_DAYS = 7

  def processing_time
    authorization_request_class = AuthorizationDefinition.find(params.expect(:definition)).authorization_request_class.to_s

    processing_days = fetch_processing_days_from_db_or_cache(authorization_request_class)

    render plain: "<turbo-frame id='processing-time'>~#{processing_days} jours</turbo-frame>", content_type: 'text/html'
  rescue StandardError
    render plain: "<turbo-frame id='processing-time'>~11 jours (estimation historique)</turbo-frame>", content_type: 'text/html'
  end

  private

  def fetch_processing_days_from_db_or_cache(authorization_request_class)
    cache_key = "processing_days_v2_#{authorization_request_class}"

    Rails.cache.fetch(cache_key, expires_in: 1.week) do
      date_range = 3.months.ago.beginning_of_day..Time.current.end_of_day
      query = Stats::TimeToFinalInstructionQuery.new(
        date_range: date_range,
        authorization_types: [authorization_request_class]
      )
      p50_seconds = query.percentiles[:p50]
      p50_seconds ? (p50_seconds / 1.day.to_i).round : DEFAULT_PROCESSING_DAYS
    end
  end
end
