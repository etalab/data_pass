module Stats
  class BaseStatsQuery
    attr_reader :date_range, :providers, :authorization_types, :forms

    def initialize(date_range:, providers: nil, authorization_types: nil, forms: nil)
      @date_range = date_range
      @providers = providers
      @authorization_types = authorization_types
      @forms = forms
    end

    protected

    def filtered_requests
      requests = AuthorizationRequest.where(created_at: date_range)
      requests = filter_by_providers(requests) if providers.present?
      requests = filter_by_authorization_types(requests) if authorization_types.present?
      requests = filter_by_forms(requests) if forms.present?
      requests
    end

    def filter_by_providers(requests)
      types_for_providers = providers.flat_map do |provider_slug|
        AuthorizationDefinition.all
          .select { |definition| definition.provider&.slug == provider_slug }
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

    def calculate_percentile_50(relation, expression)
      calculate_percentile(relation, expression, 0.5)
    end

    def calculate_percentile_90(relation, expression)
      calculate_percentile(relation, expression, 0.90)
    end

    def calculate_percentile(relation, expression, percentile)
      return nil unless relation.exists?

      result = ActiveRecord::Base.connection.execute(
        "SELECT PERCENTILE_CONT(#{percentile}) WITHIN GROUP (ORDER BY duration) as percentile_value " \
        "FROM (#{relation.select("#{expression} as duration").to_sql}) as durations"
      )
      result.first&.fetch('percentile_value', nil)&.to_f
    end

    def first_event_subquery(event_name, _alias_name = nil)
      AuthorizationRequestEvent
        .select('authorization_request_id, MIN(created_at) as event_time')
        .where(name: event_name)
        .where.not(authorization_request_id: nil)
        .group(:authorization_request_id)
    end

    def join_first_event(event_name, alias_name)
      subquery = first_event_subquery(event_name, alias_name)

      <<-SQL.squish
        INNER JOIN (#{subquery.to_sql}) #{alias_name}
        ON #{alias_name}.authorization_request_id = authorization_requests.id
      SQL
    end

    def time_difference_sql(later_event_alias, earlier_event_alias)
      "EXTRACT(EPOCH FROM (#{later_event_alias}.event_time - #{earlier_event_alias}.event_time))"
    end
  end
end
