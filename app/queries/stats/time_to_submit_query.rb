module Stats
  class TimeToSubmitQuery < DurationStatsQuery
    protected

    def requests_with_events
      AuthorizationRequest
        .select('authorization_requests.*')
        .where(id: filtered_requests.select(:id))
        .joins(first_create_event_join)
        .joins(first_submit_event_join)
        .where('first_submit_events.event_time >= first_create_events.event_time')
    end

    def duration_expression
      time_difference_sql('first_submit_events', 'first_create_events')
    end

    def first_create_event_join
      join_first_event_of_type('create', 'first_create_events')
    end

    def first_submit_event_join
      join_first_event_of_type('submit', 'first_submit_events')
    end
  end
end
