module Stats
  class BreakdownStatsQuery < BaseStatsQuery
    def by_provider
      volume_breakdown_by_provider
    end

    def by_type
      volume_breakdown_by_type
    end

    def by_form
      volume_breakdown_by_form
    end

    def volume_breakdown_by_provider
      requests_by_type = filtered_requests.group(:type).count

      grouped_by_provider = requests_by_type.each_with_object({}) do |(type, count), hash|
        definition = AuthorizationDefinition.find(type.demodulize.underscore)
        provider_slug = definition.provider&.slug
        next unless provider_slug

        hash[provider_slug] ||= { name: definition.provider.name, count: 0 }
        hash[provider_slug][:count] += count
      end

      format_breakdown_data(grouped_by_provider.values)
    end

    def volume_breakdown_by_type
      type_counts = filtered_requests.group(:type).count

      type_data = type_counts.map do |type, count|
        definition = AuthorizationDefinition.find(type.demodulize.underscore)
        {
          name: definition.name,
          count: count
        }
      end

      format_breakdown_data(type_data)
    end

    def volume_breakdown_by_form
      form_counts = filtered_requests
        .where.not(form_uid: nil)
        .group(:form_uid)
        .count

      form_data = form_counts.map do |form_uid, count|
        form = AuthorizationRequestForm.find(form_uid)
        {
          name: form.name,
          count: count
        }
      end

      format_breakdown_data(form_data)
    end

    def time_to_submit_breakdown(dimension)
      breakdown_duration_metric(dimension, Stats::TimeToSubmitQuery)
    end

    def time_to_first_instruction_breakdown(dimension)
      breakdown_duration_metric(dimension, Stats::TimeToFirstInstructionQuery)
    end

    def time_to_final_instruction_breakdown(dimension)
      breakdown_duration_metric(dimension, Stats::TimeToFinalInstructionQuery)
    end

    private

    def breakdown_duration_metric(dimension, query_class)
      case dimension
      when 'provider'
        breakdown_duration_by_provider(query_class)
      when 'type'
        breakdown_duration_by_type(query_class)
      when 'form'
        breakdown_duration_by_form(query_class)
      else
        []
      end
    end

    def breakdown_duration_by_provider(query_class)
      requests_by_type = filtered_requests.group(:type).pluck(:type)

      grouped_by_provider = requests_by_type.each_with_object({}) do |type, hash|
        definition = AuthorizationDefinition.find(type.demodulize.underscore)
        provider_slug = definition.provider&.slug
        next unless provider_slug

        types_for_provider = hash[provider_slug] ||= { name: definition.provider.name, types: [] }
        types_for_provider[:types] << type
      end

      results = grouped_by_provider.filter_map do |_slug, data|
        query = query_class.new(
          date_range: date_range,
          authorization_types: data[:types]
        )
        median = query.median
        next if median.nil?

        {
          name: data[:name],
          value: median.to_f
        }
      end

      format_duration_breakdown_data(results)
    end

    def breakdown_duration_by_type(query_class)
      type_list = filtered_requests.distinct.pluck(:type)

      results = type_list.filter_map do |type|
        definition = AuthorizationDefinition.find(type.demodulize.underscore)
        query = query_class.new(
          date_range: date_range,
          authorization_types: [type]
        )
        median = query.median
        next if median.nil?

        {
          name: definition.name,
          value: median.to_f
        }
      end

      format_duration_breakdown_data(results)
    end

    def breakdown_duration_by_form(query_class)
      form_uids = filtered_requests
        .where.not(form_uid: nil)
        .distinct
        .pluck(:form_uid)

      results = form_uids.filter_map do |form_uid|
        form = AuthorizationRequestForm.find(form_uid)
        query = query_class.new(
          date_range: date_range,
          providers: providers,
          authorization_types: authorization_types,
          forms: [form_uid]
        )
        median = query.median
        next if median.nil?

        {
          name: form.name,
          value: median.to_f
        }
      end

      format_duration_breakdown_data(results)
    end

    def format_breakdown_data(data)
      total = data.sum { |item| item[:count] }
      return [] if total.zero?

      data.sort_by { |item| -item[:count] }.map do |item|
        {
          label: item[:name],
          value: item[:count],
          percentage: ((item[:count].to_f / total) * 100).round(1)
        }
      end
    end

    def format_duration_breakdown_data(data)
      return [] if data.empty?

      max_value = data.pluck(:value).max
      return [] if max_value.zero?

      data.sort_by { |item| -item[:value] }.map do |item|
        {
          label: item[:name],
          value: item[:value].round(0),
          percentage: ((item[:value] / max_value) * 100).round(1)
        }
      end
    end
  end
end
