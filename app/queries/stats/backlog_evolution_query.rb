class Stats::BacklogEvolutionQuery < Stats::BaseStatsQuery
  def calculate_backlog_for_periods(periods)
    return {} if periods.empty?

    base_requests = filtered_requests

    return periods.index_with { 0 } unless base_requests.exists?

    timestamps = periods.map { |period| Date.parse(period).end_of_day }
    result = execute_backlog_query_for_periods(timestamps, base_requests)
    map_results_to_periods(periods, result)
  end

  private

  def map_results_to_periods(periods, result)
    backlog_by_index = result.to_a.to_h { |row| [row['period_index'].to_i, row['count'].to_i] }
    periods.each_with_index.to_h { |period, i| [period, backlog_by_index[i] || 0] }
  end

  def execute_backlog_query_for_periods(timestamps, base_requests)
    sql_params = build_timestamp_params(timestamps, base_requests)
    sql_query = backlog_count_for_periods_sql(timestamps.size)

    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array([sql_query, sql_params])
    )
  end

  def build_timestamp_params(timestamps, base_requests)
    timestamp_params = timestamps.each_with_index.to_h { |ts, i| [:"timestamp_#{i}", ts] }
    { request_ids: base_requests.select(:id) }.merge(timestamp_params)
  end

  def backlog_count_for_periods_sql(num_periods)
    queries = (0...num_periods).map { |i| single_period_backlog_query(i) }
    queries.join(' UNION ALL ')
  end

  def single_period_backlog_query(index)
    <<~SQL.squish
      SELECT #{index} as period_index, COUNT(*) as count
      FROM (#{latest_submits_subquery(index)}) ls
      LEFT JOIN (#{latest_instructions_subquery(index)}) li
        ON ls.authorization_request_id = li.authorization_request_id
      WHERE li.last_instruction_at IS NULL OR li.last_instruction_at < ls.last_submit_at
    SQL
  end

  def latest_submits_subquery(index)
    <<~SQL.squish
      SELECT authorization_request_id, MAX(created_at) as last_submit_at
      FROM authorization_request_events
      WHERE name = 'submit' AND created_at <= :timestamp_#{index}
        AND authorization_request_id IN (:request_ids)
      GROUP BY authorization_request_id
    SQL
  end

  def latest_instructions_subquery(index)
    <<~SQL.squish
      SELECT authorization_request_id, MAX(created_at) as last_instruction_at
      FROM authorization_request_events
      WHERE name IN ('approve', 'refuse', 'request_changes')
        AND created_at <= :timestamp_#{index}
        AND authorization_request_id IN (:request_ids)
      GROUP BY authorization_request_id
    SQL
  end
end
