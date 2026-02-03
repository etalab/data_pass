module Stats
  class TimeSeriesQuery < BaseStatsQuery
    def time_series_data
      time_unit = determine_time_unit
      {
        unit: time_unit,
        data: fetch_time_series_data(time_unit)
      }
    end

    private

    def determine_time_unit
      days_in_range = (date_range.end - date_range.begin).to_i

      return 'day' if days_in_range <= 31
      return 'week' if days_in_range <= 183
      return 'month' if days_in_range <= 730

      'year'
    end

    def fetch_time_series_data(time_unit)
      trunc_format = time_unit_to_postgres_format(time_unit)

      new_requests_by_period = fetch_new_requests_by_period(trunc_format)
      reopenings_by_period = fetch_reopenings_by_period(trunc_format)
      validations_by_period = fetch_validations_by_period(trunc_format)
      refusals_by_period = fetch_refusals_by_period(trunc_format)

      all_periods = collect_all_periods([
        new_requests_by_period,
        reopenings_by_period,
        validations_by_period,
        refusals_by_period
      ])

      all_periods.sort.map do |period|
        {
          period: period,
          new_requests: new_requests_by_period[period] || 0,
          reopenings: reopenings_by_period[period] || 0,
          validations: validations_by_period[period] || 0,
          refusals: refusals_by_period[period] || 0
        }
      end
    end

    def time_unit_to_postgres_format(time_unit)
      {
        'day' => 'day',
        'week' => 'week',
        'month' => 'month',
        'year' => 'year'
      }[time_unit]
    end

    def fetch_new_requests_by_period(trunc_format)
      result = filtered_requests_with_first_submit_in_range
        .group("DATE_TRUNC('#{trunc_format}', first_submits.first_submit_time)")
        .count

      result.transform_keys { |key| key.to_date.iso8601 }
    end

    def fetch_reopenings_by_period(trunc_format)
      authorization_request_ids = filtered_requests.pluck(:id)

      reopen_events = AuthorizationRequestEvent
        .where(name: 'reopen')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .select(:id, :authorization_request_id, :created_at)

      grouped_reopenings = reopen_events.group_by do |event|
        truncate_date(event.created_at, trunc_format).to_date.iso8601
      end

      grouped_reopenings.transform_values do |events|
        events.count { |event| subsequent_submit?(event) }
      end
    end

    def fetch_validations_by_period(trunc_format)
      authorization_request_ids = filtered_requests.pluck(:id)

      result = AuthorizationRequestEvent
        .where(name: 'approve')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .group("DATE_TRUNC('#{trunc_format}', created_at)")
        .count

      result.transform_keys { |key| key.to_date.iso8601 }
    end

    def fetch_refusals_by_period(trunc_format)
      authorization_request_ids = filtered_requests.pluck(:id)

      result = AuthorizationRequestEvent
        .where(name: 'refuse')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .group("DATE_TRUNC('#{trunc_format}', created_at)")
        .count

      result.transform_keys { |key| key.to_date.iso8601 }
    end

    def filtered_requests_with_first_submit_in_range
      filtered_requests
        .joins(<<-SQL.squish)
          INNER JOIN (
            SELECT authorization_request_id, MIN(created_at) as first_submit_time
            FROM authorization_request_events
            WHERE name = 'submit'
            AND authorization_request_id IS NOT NULL
            GROUP BY authorization_request_id
          ) first_submits ON first_submits.authorization_request_id = authorization_requests.id
        SQL
        .where(first_submits: { first_submit_time: date_range.begin.. })
        .where(first_submits: { first_submit_time: ..date_range.end })
    end

    def subsequent_submit?(reopen_event)
      AuthorizationRequestEvent
        .where(name: 'submit')
        .where(authorization_request_id: reopen_event.authorization_request_id)
        .exists?(['created_at > ?', reopen_event.created_at])
    end

    def truncate_date(date, trunc_format)
      case trunc_format
      when 'day'
        date.beginning_of_day
      when 'week'
        date.beginning_of_week
      when 'month'
        date.beginning_of_month
      when 'year'
        date.beginning_of_year
      end
    end

    def collect_all_periods(period_hashes)
      period_hashes.flat_map(&:keys).uniq
    end
  end
end
