class Stats::TimeToSubmitQuery < Stats::DurationStatsQuery
  protected

  def requests_with_events
    AuthorizationRequest
      .select('authorization_requests.*')
      .where(id: filtered_requests_with_first_submit_in_range.select(:id))
      .joins(first_create_event_join)
      .joins(first_submit_event_join)
      .where('first_submit_events.event_time >= first_create_events.event_time')
  end

  def later_event_alias
    'first_submit_events'
  end

  def earlier_event_alias
    'first_create_events'
  end

  def first_create_event_join
    join_first_event('create', 'first_create_events')
  end

  def first_submit_event_join
    join_first_event('submit', 'first_submit_events')
  end
end
