class Stats::DurationStatsQuery < Stats::BaseStatsQuery
  MINIMUM_DURATION_SECONDS = 60

  def percentiles
    @percentiles ||= calculate_percentiles(
      requests_with_events_filtered,
      time_difference_sql(later_event_alias, earlier_event_alias)
    )
  end

  protected

  def requests_with_events
    raise NotImplementedError, 'Subclasses must implement requests_with_events'
  end

  def later_event_alias
    raise NotImplementedError, 'Subclasses must implement later_event_alias'
  end

  def earlier_event_alias
    raise NotImplementedError, 'Subclasses must implement earlier_event_alias'
  end

  def requests_with_events_filtered
    requests_with_events.where(
      minimum_duration_condition(later_event_alias, earlier_event_alias),
      MINIMUM_DURATION_SECONDS
    )
  end

  private

  def minimum_duration_condition(later, earlier)
    raise ArgumentError, "Invalid alias: #{later}" unless ALLOWED_EVENT_ALIASES.include?(later)
    raise ArgumentError, "Invalid alias: #{earlier}" unless ALLOWED_EVENT_ALIASES.include?(earlier)

    "EXTRACT(EPOCH FROM (#{later}.event_time - #{earlier}.event_time)) >= ?"
  end
end
