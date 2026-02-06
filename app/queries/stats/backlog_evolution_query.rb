module Stats
  class BacklogEvolutionQuery < BaseStatsQuery
    private

    def filtered_requests_for_backlog
      requests = AuthorizationRequest.all
      requests = filter_by_providers(requests) if providers.present?
      requests = filter_by_authorization_types(requests) if authorization_types.present?
      requests = filter_by_forms(requests) if forms.present?
      requests
    end

    def calculate_backlog_at(timestamp)
      base_requests = filtered_requests_for_backlog
        .where.not(state: %w[archived revoked])

      return 0 unless base_requests.exists?

      result = ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array([
          backlog_count_sql,
          { timestamp: timestamp, request_ids: base_requests.select(:id) }
        ])
      )

      result.first['count'].to_i
    end

    def backlog_count_sql
      <<-SQL.squish
        WITH latest_submits AS (
          SELECT
            authorization_request_id,
            MAX(created_at) as last_submit_at
          FROM authorization_request_events
          WHERE name = 'submit'
            AND created_at <= :timestamp
            AND authorization_request_id IN (:request_ids)
          GROUP BY authorization_request_id
        ),
        latest_instructions AS (
          SELECT
            authorization_request_id,
            MAX(created_at) as last_instruction_at
          FROM authorization_request_events
          WHERE name IN ('approve', 'refuse', 'request_changes')
            AND created_at <= :timestamp
            AND authorization_request_id IN (:request_ids)
          GROUP BY authorization_request_id
        )
        SELECT COUNT(*)
        FROM latest_submits ls
        LEFT JOIN latest_instructions li
          ON ls.authorization_request_id = li.authorization_request_id
        WHERE li.last_instruction_at IS NULL
          OR li.last_instruction_at < ls.last_submit_at
      SQL
    end
  end
end
