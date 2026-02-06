module Stats
  class VolumeStatsQuery < BaseStatsQuery
    def total_requests_submitted_count
      authorization_request_ids = filtered_requests.pluck(:id)

      AuthorizationRequestEvent
        .where(name: 'submit')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .count
    end

    def new_requests_submitted_count
      filtered_requests_with_first_submit_in_range.count
    end

    def reopenings_submitted_count
      reopen_events_in_range.count do |reopen_event|
        subsequent_submit?(reopen_event)
      end
    end

    def validations_count
      authorization_request_ids = filtered_requests.pluck(:id)

      AuthorizationRequestEvent
        .where(name: 'approve')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .count
    end

    def refusals_count
      authorization_request_ids = filtered_requests.pluck(:id)

      AuthorizationRequestEvent
        .where(name: 'refuse')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .count
    end

    private

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

    def reopen_events_in_range
      authorization_request_ids = filtered_requests.pluck(:id)

      AuthorizationRequestEvent
        .where(name: 'reopen')
        .where(authorization_request_id: authorization_request_ids)
        .where(created_at: date_range)
        .select(:id, :authorization_request_id, :created_at)
    end

    def subsequent_submit?(reopen_event)
      AuthorizationRequestEvent
        .where(name: 'submit')
        .where(authorization_request_id: reopen_event.authorization_request_id)
        .exists?(['created_at > ?', reopen_event.created_at])
    end
  end
end
