module Stats
  class Aggregator
    def initialize(authorization_requests=nil)
      @authorization_requests = authorization_requests || AuthorizationRequest.all
    end

    def time_to_submit
      @authorization_requests
        .joins(:events_without_bulk_update)
        .where(events_without_bulk_update: { name: 'submit' })
        .where("events_without_bulk_update.created_at >= authorization_requests.created_at")
        .average("EXTRACT(EPOCH FROM (events_without_bulk_update.created_at - authorization_requests.created_at))")
    end

    def min_time_to_submit
      @authorization_requests
        .joins(:events_without_bulk_update)
        .where(events_without_bulk_update: { name: 'submit' })
        .where("events_without_bulk_update.created_at >= authorization_requests.created_at")
        .minimum("EXTRACT(EPOCH FROM (events_without_bulk_update.created_at - authorization_requests.created_at))")
    end

    def max_time_to_submit
      @authorization_requests
        .joins(:events_without_bulk_update)
        .where(events_without_bulk_update: { name: 'submit' })
        .where("events_without_bulk_update.created_at >= authorization_requests.created_at")
        .maximum("EXTRACT(EPOCH FROM (events_without_bulk_update.created_at - authorization_requests.created_at))")
    end
  end
end