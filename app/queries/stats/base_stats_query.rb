class Stats::BaseStatsQuery
  ALLOWED_EVENT_ALIASES = %w[
    first_create_events first_submit_events submit_events
    first_instruction_events final_decision_events
  ].freeze

  attr_reader :date_range, :providers, :authorization_types, :forms

  def initialize(date_range:, providers: nil, authorization_types: nil, forms: nil)
    @date_range = date_range
    @providers = providers
    @authorization_types = authorization_types
    @forms = forms
  end

  protected

  def filtered_requests
    @filtered_requests ||= begin
      requests = AuthorizationRequest.all
      requests = filter_by_providers(requests) if providers.present?
      requests = filter_by_authorization_types(requests) if authorization_types.present?
      requests = filter_by_forms(requests) if forms.present?
      requests
    end
  end

  def filter_by_providers(requests)
    types_for_providers = providers.flat_map do |provider_slug|
      AuthorizationDefinition.all
        .select { |definition| definition.provider_slug == provider_slug }
        .map { |definition| definition.authorization_request_class.name }
    end

    return requests.none if types_for_providers.empty?

    requests.where(type: types_for_providers)
  end

  def filter_by_authorization_types(requests)
    requests.where(type: authorization_types)
  end

  def filter_by_forms(requests)
    requests.where(form_uid: forms)
  end

  def calculate_percentiles(relation, expression)
    return { p50: nil, p90: nil } unless relation.exists?

    subquery = relation.select(Arel.sql("#{expression} as duration")).to_sql

    result = ActiveRecord::Base.connection.execute(
      'SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration) as p50, ' \
      'PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY duration) as p90 ' \
      "FROM (#{subquery}) as durations"
    )
    row = result.first
    { p50: row&.fetch('p50', nil)&.to_f, p90: row&.fetch('p90', nil)&.to_f }
  end

  def first_event_subquery(event_name)
    AuthorizationRequestEvent
      .select('authorization_request_id, MIN(created_at) as event_time')
      .where(name: event_name)
      .where.not(authorization_request_id: nil)
      .group(:authorization_request_id)
  end

  def join_first_event(event_name, alias_name)
    raise ArgumentError, "Invalid alias: #{alias_name}" unless ALLOWED_EVENT_ALIASES.include?(alias_name)

    subquery = first_event_subquery(event_name)

    <<~SQL.squish
      INNER JOIN (#{subquery.to_sql}) #{alias_name}
      ON #{alias_name}.authorization_request_id = authorization_requests.id
    SQL
  end

  def time_difference_sql(later_event_alias, earlier_event_alias)
    raise ArgumentError, "Invalid alias: #{later_event_alias}" unless ALLOWED_EVENT_ALIASES.include?(later_event_alias)
    raise ArgumentError, "Invalid alias: #{earlier_event_alias}" unless ALLOWED_EVENT_ALIASES.include?(earlier_event_alias)

    "EXTRACT(EPOCH FROM (#{later_event_alias}.event_time - #{earlier_event_alias}.event_time))"
  end

  def filtered_requests_with_first_submit_in_range
    filtered_requests
      .joins(<<~SQL.squish)
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

  def reopenings_with_subsequent_submit
    AuthorizationRequestEvent
      .where(name: 'reopen')
      .where(authorization_request_id: filtered_requests.select(:id))
      .where(created_at: date_range)
      .where(subsequent_submit_exists_sql, 'submit')
  end

  def subsequent_submit_exists_sql
    <<~SQL.squish
      EXISTS (
        SELECT 1 FROM authorization_request_events submit_events
        WHERE submit_events.name = ?
        AND submit_events.authorization_request_id = authorization_request_events.authorization_request_id
        AND submit_events.created_at > authorization_request_events.created_at
      )
    SQL
  end
end
