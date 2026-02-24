class StatsController < PublicController
  helper_method :user_signed_in?

  rate_limit to: 60, within: 1.minute, only: %i[data filters]

  def index; end

  def filters
    result = Rails.cache.fetch('stats/filters', expires_in: 1.hour) do
      Stats::FiltersFacade.new.to_h
    end

    render json: result
  end

  def data
    render json: (
      Rails.cache.fetch(stats_cache_key, expires_in: 5.minutes) do
        stats_data_result = Stats::FetchStatsData.call(stats_data_context)
        {
          volume: stats_data_result.volume,
          time_series: stats_data_result.time_series,
          durations: stats_data_result.durations
        }
      end
    )
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def stats_data_context
    {
      date_range: date_range,
      providers: parse_array_param(params[:providers]),
      authorization_types: parse_array_param(params[:authorization_types]),
      forms: parse_array_param(params[:forms])
    }
  end

  def stats_cache_key
    [
      'stats/data',
      start_date.iso8601,
      end_date.iso8601,
      sorted_array_param(:providers).inspect,
      sorted_array_param(:authorization_types).inspect,
      sorted_array_param(:forms).inspect
    ].join('/')
  end

  def sorted_array_param(key)
    Array(parse_array_param(params[key])).sort
  end

  def date_range
    raise ArgumentError, I18n.t('stats.errors.start_before_end') if start_date > end_date

    start_date.beginning_of_day..end_date.end_of_day
  end

  def start_date
    @start_date ||= parse_date(params[:start_date]) || 1.year.ago.to_date
  end

  def end_date
    @end_date ||= parse_date(params[:end_date]) || Date.current
  end

  def parse_date(date_string)
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue Date::Error, TypeError
    raise ArgumentError, I18n.t('stats.errors.invalid_date_format')
  end

  def parse_array_param(param)
    return nil if param.blank?

    param.is_a?(Array) ? param : [param]
  end
end
