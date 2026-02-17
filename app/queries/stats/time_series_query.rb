class Stats::TimeSeriesQuery < Stats::BaseStatsQuery
  ALLOWED_TRUNC_FORMATS = %w[day week month year].freeze
  ALLOWED_COLUMN_NAMES = %w[created_at first_submits.first_submit_time].freeze

  def time_series_data
    time_unit = determine_time_unit
    {
      unit: time_unit,
      data: fetch_time_series_data(time_unit)
    }
  end

  private

  def determine_time_unit
    days_in_range = (date_range.end.to_date - date_range.begin.to_date).to_i

    return 'day' if days_in_range <= 31
    return 'week' if days_in_range <= 183
    return 'month' if days_in_range <= 730

    'year'
  end

  def fetch_time_series_data(time_unit)
    raise ArgumentError, "Invalid time unit: #{time_unit}" unless ALLOWED_TRUNC_FORMATS.include?(time_unit)

    period_data = fetch_all_period_data(time_unit)

    build_time_series_from_periods(period_data)
  end

  def fetch_all_period_data(trunc_format)
    {
      new_requests: fetch_new_requests_by_period(trunc_format),
      reopenings: fetch_reopenings_by_period(trunc_format),
      validations: fetch_validations_by_period(trunc_format),
      refusals: fetch_refusals_by_period(trunc_format)
    }
  end

  def build_time_series_from_periods(period_data)
    all_periods = collect_all_periods(period_data.values)

    all_periods.sort.map do |period|
      build_period_entry(period, period_data)
    end
  end

  def build_period_entry(period, period_data)
    {
      period: period,
      new_requests: period_data[:new_requests][period] || 0,
      reopenings: period_data[:reopenings][period] || 0,
      validations: period_data[:validations][period] || 0,
      refusals: period_data[:refusals][period] || 0
    }
  end

  def date_trunc_expression(trunc_format, column_name)
    raise ArgumentError, "Invalid trunc format: #{trunc_format}" unless ALLOWED_TRUNC_FORMATS.include?(trunc_format)
    raise ArgumentError, "Invalid column name: #{column_name}" unless ALLOWED_COLUMN_NAMES.include?(column_name)

    Arel.sql("DATE_TRUNC('#{trunc_format}', #{column_name})")
  end

  def fetch_new_requests_by_period(trunc_format)
    result = filtered_requests_with_first_submit_in_range
      .group(date_trunc_expression(trunc_format, 'first_submits.first_submit_time'))
      .count

    result.transform_keys { |key| key.to_date.iso8601 }
  end

  def fetch_reopenings_by_period(trunc_format)
    result = reopenings_with_subsequent_submit
      .group(date_trunc_expression(trunc_format, 'created_at'))
      .count

    result.transform_keys { |key| key.to_date.iso8601 }
  end

  def fetch_validations_by_period(trunc_format)
    result = AuthorizationRequestEvent
      .where(name: 'approve')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .group(date_trunc_expression(trunc_format, 'created_at'))
      .count

    result.transform_keys { |key| key.to_date.iso8601 }
  end

  def fetch_refusals_by_period(trunc_format)
    result = AuthorizationRequestEvent
      .where(name: 'refuse')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .group(date_trunc_expression(trunc_format, 'created_at'))
      .count

    result.transform_keys { |key| key.to_date.iso8601 }
  end

  def collect_all_periods(period_hashes)
    period_hashes.flat_map(&:keys).uniq
  end
end
