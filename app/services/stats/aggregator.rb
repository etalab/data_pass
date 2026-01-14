module Stats
  class Aggregator
    def initialize(authorization_requests=nil)
      @authorization_requests = authorization_requests || AuthorizationRequest.all
    end

    def average_time_to_submit
      authorizations_with_first_create_and_submit_events.average("EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time))")
    end

    def median_time_to_submit
      result = authorizations_with_first_create_and_submit_events
        .pluck(Arel.sql("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"))
        .first
      
      result&.to_f
    end

    def stddev_time_to_submit
      result = authorizations_with_first_create_and_submit_events
        .pluck(Arel.sql("STDDEV_POP(EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"))
        .first
      
      result&.to_f
    end

    def average_time_to_first_instruction
      authorizations_with_submit_and_first_instruction_events.average("EXTRACT(EPOCH FROM (first_instruction_events.event_time - submit_events.event_time))")
    end

    def median_time_to_first_instruction
      result = authorizations_with_submit_and_first_instruction_events
        .pluck(Arel.sql("PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (first_instruction_events.event_time - submit_events.event_time)))"))
        .first
      
      result&.to_f
    end

    def stddev_time_to_first_instruction
      result = authorizations_with_submit_and_first_instruction_events
        .pluck(Arel.sql("STDDEV_POP(EXTRACT(EPOCH FROM (first_instruction_events.event_time - submit_events.event_time)))"))
        .first
      
      result&.to_f
    end

    def first_create_events_subquery
      first_event_subquery('create')
    end

    def reopen_events_count
      # Find reopen events for the authorization requests
      authorization_request_ids = @authorization_requests.pluck(:id)
      
      reopen_events = AuthorizationRequestEvent
        .where(name: 'reopen')
        .where(authorization_request_id: authorization_request_ids)
        .select(:id, :authorization_request_id, :created_at)

      # Count only those reopens that have a subsequent submit event
      reopen_events.select do |reopen_event|
        AuthorizationRequestEvent
          .where(name: 'submit')
          .where(authorization_request_id: reopen_event.authorization_request_id)
          .where('created_at > ?', reopen_event.created_at)
          .exists?
      end.count
    end

    def time_to_submit_by_type
      results = authorizations_with_first_create_and_submit_events
        .group("authorization_requests.type")
        .order(Arel.sql("AVG(EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"))
        .pluck(
          Arel.sql("authorization_requests.type"),
          Arel.sql("MIN(EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"),
          Arel.sql("AVG(EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"),
          Arel.sql("MAX(EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time)))"),
          Arel.sql("COUNT(*)")
        )
      
      results.map do |type, min_time, avg_time, max_time, count|
        {
          type: type,
          min_time: min_time&.to_f,
          avg_time: avg_time&.to_f,
          max_time: max_time&.to_f,
          count: count
        }
      end
    end

    def time_to_submit_by_duration_buckets(step: :day)
      step_config = step_configuration(step)
      step_seconds = step_config[:seconds]
      max_steps = step_config[:max_steps]
      
      # Get all time to submit values in seconds
      time_values = authorizations_with_first_create_and_submit_events
        .pluck(Arel.sql("EXTRACT(EPOCH FROM (first_submit_events.event_time - first_create_events.event_time))"))
        .map(&:to_f)
      
      return [] if time_values.empty?
      
      # Initialize buckets
      buckets = {}
      buckets["<1"] = 0
      (1..max_steps).each { |i| buckets[i.to_s] = 0 }
      buckets["> #{max_steps}"] = 0
      
      # Distribute values into buckets
      time_values.each do |seconds|
        bucket_index = (seconds / step_seconds).ceil
        
        if bucket_index < 1
          buckets["<1"] += 1
        elsif bucket_index > max_steps
          buckets["> #{max_steps}"] += 1
        else
          buckets[bucket_index.to_s] += 1
        end
      end
      
      # Return as array of hashes in order
      result = [{ bucket: "<1", count: buckets["<1"] }]
      (1..max_steps).each { |i| result << { bucket: i.to_s, count: buckets[i.to_s] } }
      result << { bucket: "> #{max_steps}", count: buckets["> #{max_steps}"] }
      
      result
    end

    private

    def step_configuration(step)
      case step
      when :minute
        { seconds: 60, max_steps: 60 }
      when :hour
        { seconds: 3600, max_steps: 24 }
      when :day
        { seconds: 86400, max_steps: 30 }
      else
        raise ArgumentError, "Invalid step: #{step}. Must be :minute, :hour, or :day"
      end
    end

    def first_submit_events_subquery
      # We ignore the legacy AuthorizationRequestChangelog as they are inconsistent data generated by the migration from v1
      first_event_subquery('submit')
        .joins("LEFT JOIN authorization_request_changelogs ON authorization_request_events.entity_type = 'AuthorizationRequestChangelog' AND authorization_request_events.entity_id = authorization_request_changelogs.id")
        .where("authorization_request_changelogs.legacy IS NULL OR authorization_request_changelogs.legacy = false")
    end

    def first_event_subquery(event_name)
      AuthorizationRequestEvent
        .where(name: event_name)
        .where.not(authorization_request_id: nil)
        .group("authorization_request_events.authorization_request_id")
        .select("authorization_request_events.authorization_request_id, MIN(authorization_request_events.created_at) as event_time")
    end

    def authorizations_with_first_create_and_submit_events
      @authorization_requests
        .joins("INNER JOIN (#{first_create_events_subquery.to_sql}) first_create_events ON first_create_events.authorization_request_id = authorization_requests.id")
        .joins("INNER JOIN (#{first_submit_events_subquery.to_sql}) first_submit_events ON first_submit_events.authorization_request_id = authorization_requests.id")
        .where("first_submit_events.event_time >= first_create_events.event_time") # we have one case where the submit event is before the create event, so we need to filter it out
    end

    def authorizations_with_submit_and_first_instruction_events
      @authorization_requests
        .joins("INNER JOIN (#{submit_events_subquery.to_sql}) submit_events ON submit_events.authorization_request_id = authorization_requests.id")
        .joins("INNER JOIN (#{first_instruction_events_subquery.to_sql}) first_instruction_events ON first_instruction_events.authorization_request_id = authorization_requests.id AND first_instruction_events.submit_event_id = submit_events.event_id")
        .where("first_instruction_events.event_time > submit_events.event_time")
    end

    def submit_events_subquery
      AuthorizationRequestEvent
        .where(name: 'submit')
        .where.not(authorization_request_id: nil)
        .select("authorization_request_events.id as event_id, authorization_request_events.authorization_request_id, authorization_request_events.created_at as event_time")
    end

    def first_instruction_events_subquery
      # For each submit event, find the first instruction event (approve, refuse, or request_changes) that follows it
      AuthorizationRequestEvent
        .from("authorization_request_events AS instruction_events")
        .joins("INNER JOIN authorization_request_events AS submit_events ON instruction_events.authorization_request_id = submit_events.authorization_request_id")
        .where("submit_events.name = 'submit'")
        .where("instruction_events.name IN ('approve', 'refuse', 'request_changes')")
        .where("instruction_events.created_at > submit_events.created_at")
        .group("instruction_events.authorization_request_id, submit_events.id")
        .select(
          "instruction_events.authorization_request_id",
          "submit_events.id as submit_event_id",
          "MIN(instruction_events.created_at) as event_time"
        )
    end
  end
end
