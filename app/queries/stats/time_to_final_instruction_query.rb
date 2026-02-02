module Stats
  class TimeToFinalInstructionQuery < DurationStatsQuery
    protected

    def requests_with_events
      AuthorizationRequest
        .select('authorization_requests.*')
        .where(id: filtered_requests.select(:id))
        .joins(submit_event_join)
        .joins(final_decision_event_join)
        .where('final_decision_events.event_time >= submit_events.event_time')
    end

    def duration_expression
      time_difference_sql('final_decision_events', 'submit_events')
    end

    def submit_event_join
      join_first_event_of_type('submit', 'submit_events')
    end

    def final_decision_event_join
      subquery = AuthorizationRequestEvent
        .select('authorization_request_id, MIN(created_at) as event_time')
        .where(name: %w[approve refuse])
        .where.not(authorization_request_id: nil)
        .group(:authorization_request_id)

      <<-SQL.squish
        INNER JOIN (#{subquery.to_sql}) final_decision_events
        ON final_decision_events.authorization_request_id = authorization_requests.id
      SQL
    end
  end
end
