module Stats
  class DurationStatsQuery < BaseStatsQuery
    MINIMUM_DURATION_SECONDS = 60

    def median
      calculate_median_duration(requests_with_events_filtered, duration_expression)
    end

    def stddev
      calculate_stddev_duration(requests_with_events_filtered, duration_expression)
    end

    protected

    def requests_with_events
      raise NotImplementedError, 'Subclasses must implement requests_with_events'
    end

    def duration_expression
      raise NotImplementedError, 'Subclasses must implement duration_expression'
    end

    def requests_with_events_filtered
      requests_with_events.where("#{duration_expression} >= ?", MINIMUM_DURATION_SECONDS)
    end

    def calculate_median_duration(relation, expression)
      calculate_median(relation, expression)
    end

    def calculate_stddev_duration(relation, expression)
      calculate_stddev(relation, expression)
    end

    def join_first_event_of_type(event_name, alias_name)
      join_first_event(event_name, alias_name)
    end
  end
end
