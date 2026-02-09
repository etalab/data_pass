class Stats::TimeToFirstInstructionQuery < Stats::DurationStatsQuery
  protected

  def requests_with_events
    AuthorizationRequest
      .select('authorization_requests.*')
      .where(id: filtered_requests_with_first_submit_in_range.select(:id))
      .joins(submit_event_join)
      .joins(first_instruction_event_join)
      .where('first_instruction_events.event_time >= submit_events.event_time')
  end

  def later_event_alias
    'first_instruction_events'
  end

  def earlier_event_alias
    'submit_events'
  end

  def submit_event_join
    join_first_event('submit', 'submit_events')
  end

  def first_instruction_event_join
    subquery = AuthorizationRequestEvent
      .select('authorization_request_id, MIN(created_at) as event_time')
      .where(name: %w[approve refuse request_changes])
      .where.not(authorization_request_id: nil)
      .group(:authorization_request_id)

    <<~SQL.squish
      INNER JOIN (#{subquery.to_sql}) first_instruction_events
      ON first_instruction_events.authorization_request_id = authorization_requests.id
    SQL
  end
end
