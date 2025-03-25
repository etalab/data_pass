class ProcessingTimeQuery
  attr_reader :authorization_request_class

  def initialize(authorization_request_class = nil)
    @authorization_request_class = authorization_request_class
  end

  def perform
    result = ActiveRecord::Base.connection.exec_query(sql_query)
    result.first['average_days']
  end

  private

  # rubocop:disable Metrics/MethodLength
  def sql_query
    query = <<-SQL
      WITH submit_times AS (
          SELECT
              changelogs.authorization_request_id,
              MIN(events.created_at) AS submit_time
          FROM
              authorization_request_events events
          JOIN
              authorization_request_changelogs changelogs
          ON
              events.entity_id = changelogs.id
          WHERE
              events.name = 'submit'
              AND events.entity_type = 'AuthorizationRequestChangelog'
          GROUP BY
              changelogs.authorization_request_id
      ),
      decision_times AS (
          -- Approve events
          SELECT
              auth.request_id AS authorization_request_id,
              MIN(events.created_at) AS decision_time
          FROM
              authorization_request_events events
          JOIN
              authorizations auth
          ON
              events.entity_id = auth.id
          WHERE
              events.name = 'approve'
              AND events.entity_type = 'Authorization'
              AND events.created_at >= CURRENT_DATE - INTERVAL '6 months'
          GROUP BY
              auth.request_id
          UNION ALL
          -- Refuse events
          SELECT
              denial.authorization_request_id,
              MIN(events.created_at) AS decision_time
          FROM
              authorization_request_events events
          JOIN
              denial_of_authorizations denial
          ON
              events.entity_id = denial.id
          WHERE
              events.name = 'refuse'
              AND events.entity_type = 'DenialOfAuthorization'
              AND events.created_at >= CURRENT_DATE - INTERVAL '6 months'
          GROUP BY
              denial.authorization_request_id
      )
      SELECT
          COALESCE(ROUND(AVG(EXTRACT(EPOCH FROM (decision_times.decision_time - submit_times.submit_time)) / 86400))::INTEGER, 0) AS average_days
      FROM
          submit_times
      JOIN
          decision_times
      ON
          submit_times.authorization_request_id = decision_times.authorization_request_id
      JOIN
          authorization_requests ar
      ON
          submit_times.authorization_request_id = ar.id
      WHERE
          decision_times.decision_time > submit_times.submit_time
          AND EXTRACT(EPOCH FROM (decision_times.decision_time - submit_times.submit_time)) / 86400 <= 180
    SQL

    query += " AND ar.type = #{ActiveRecord::Base.connection.quote(authorization_request_class)}" if authorization_request_class.present?

    query
  end
  # rubocop:enable Metrics/MethodLength
end
