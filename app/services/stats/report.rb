module Stats
  class Report
    include ActionView::Helpers::DateHelper

    def initialize(date_input: 2025, authorization_types: nil, provider: nil)
      @date_input = date_input
      @date_range = extract_date_range(date_input)
      @provider = provider
      @authorization_types = authorization_types || authorization_types_from_provider
      
      @authorization_requests_created_in_range = authorization_requests_with_first_create_in_range
      @create_aggregator = Stats::Aggregator.new(@authorization_requests_created_in_range)

      @authorization_requests_with_reopen_in_range = authorization_requests_with_reopen_events_in_range
      @reopen_aggregator = Stats::Aggregator.new(@authorization_requests_with_reopen_in_range)

      @authorization_requests_with_start_next_stage_in_range = authorization_requests_with_start_next_stage_events_in_range
      @production_aggregator = Stats::Aggregator.new(@authorization_requests_with_start_next_stage_in_range)

      @authorization_requests_with_approve_in_range = authorization_requests_with_approve_events_in_range
      @approve_aggregator = Stats::Aggregator.new(@authorization_requests_with_approve_in_range)

      @authorization_requests_with_refuse_in_range = authorization_requests_with_refuse_events_in_range
      @refuse_aggregator = Stats::Aggregator.new(@authorization_requests_with_refuse_in_range)
    end

    def print_report
      result =  " \n# 📊 Rapport de #{human_readable_date_range}#{type_filter_label}:\n\n"
      result += "## Volume\n"
      result += "- #{number_of_authorization_requests_created}\n"
      result += "- #{number_of_reopen_events}\n"
      result += "- #{number_of_validated_events}\n"
      result += "- #{number_of_refused_events}\n"
      result += "## Durée d'une soumission\n"
      result += "(Entre la création d'une demande et sa première soumission)\n"
      result += "- #{average_time_to_submit}\n- #{median_time_to_submit}\n- #{mode_time_to_submit}\n- #{stddev_time_to_submit}\n"
      result += "## Durée de première instruction\n"
      result += "(Entre une soumission et la première instruction qui suit)\n"
      result += "- #{average_time_to_first_instruction}\n- #{median_time_to_first_instruction}\n- #{mode_time_to_first_instruction}\n- #{stddev_time_to_first_instruction}\n"
      
      if dgfip_report?
        result += "## Durée de première instruction de production\n"
        result += "(Entre le premier événement start_next_stage et la première instruction qui suit)\n"
        result += "- #{average_time_to_production_instruction}\n- #{median_time_to_production_instruction}\n- #{mode_time_to_production_instruction}\n- #{stddev_time_to_production_instruction}\n"
      end
      
      puts result
    end

    def number_of_authorization_requests_created
      "#{@authorization_requests_created_in_range.count} demandes créées"
    end

    def number_of_reopen_events
      "#{@reopen_aggregator.reopen_events_count} réouvertures"
    end

    def number_of_validated_events
      "#{@approve_aggregator.validated_events_count(@date_range)} validations"
    end

    def number_of_refused_events
      "#{@refuse_aggregator.refused_events_count(@date_range)} refus"
    end

    def average_time_to_submit
      format_metric('Durée moyenne d\'une soumission', @create_aggregator.average_time_to_submit)
    end

    def median_time_to_submit
      format_metric('Durée médiane d\'une soumission', @create_aggregator.median_time_to_submit)
    end

    def stddev_time_to_submit
      format_metric('Écart-type des durées de soumission', @create_aggregator.stddev_time_to_submit)
    end

    def mode_time_to_submit
      format_metric('Durée de soumission la plus fréquente', @create_aggregator.mode_time_to_submit)
    end

    def average_time_to_first_instruction
      format_metric('Durée moyenne d\'une instruction', @create_aggregator.average_time_to_first_instruction)
    end

    def median_time_to_first_instruction
      format_metric('Durée médiane d\'une instruction', @create_aggregator.median_time_to_first_instruction)
    end

    def stddev_time_to_first_instruction
      format_metric('Écart-type des durées d\'instruction', @create_aggregator.stddev_time_to_first_instruction)
    end

    def mode_time_to_first_instruction
      format_metric('Durée d\'instruction la plus fréquente', @create_aggregator.mode_time_to_first_instruction)
    end

    def average_time_to_production_instruction
      format_metric('Durée moyenne d\'une instruction production', @production_aggregator.average_time_to_production_instruction)
    end

    def median_time_to_production_instruction
      format_metric('Durée médiane d\'une instruction production', @production_aggregator.median_time_to_production_instruction)
    end

    def stddev_time_to_production_instruction
      format_metric('Écart-type des durées d\'instruction production', @production_aggregator.stddev_time_to_production_instruction)
    end

    def mode_time_to_production_instruction
      format_metric('Durée d\'instruction production la plus fréquente', @production_aggregator.mode_time_to_production_instruction)
    end

    def dgfip_report?
      @provider == 'dgfip'
    end

    def print_time_to_submit_by_type_table
      stats = @create_aggregator.time_to_submit_by_type
      
      if stats.empty?
        puts "\nAucune donnée disponible pour les statistiques par type."
        return
      end

      puts "\n## Durée de soumission par type de demande de #{human_readable_date_range}#{type_filter_label}:\n\n"
      puts format_table_header
      puts format_table_separator(stats)
      
      stats.each do |stat|
        puts format_table_row(stat)
      end
    end

    def time_to_submit_by_type_table
      stats = @create_aggregator.time_to_submit_by_type
      return "Aucune donnée disponible" if stats.empty?

      lines = []
      lines << format_table_header
      lines << format_table_separator(stats)
      stats.each { |stat| lines << format_table_row(stat) }
      lines.join("\n")
    end

    def print_time_to_submit_by_duration(step: :day)
      buckets = @create_aggregator.time_to_submit_by_duration_buckets(step: step)
      print_chart_with_title(buckets, "Durée de soumission par #{step_label_text(step)}", preposition: 'de')
    end

    def print_time_to_first_instruction_by_duration(step: :day)
      buckets = @create_aggregator.time_to_first_instruction_by_duration_buckets(step: step)
      print_chart_with_title(buckets, "Durée de première instruction par #{step_label_text(step)}", preposition: 'de')
    end

    def print_volume_by_type
      data = @create_aggregator.volume_by_type
      buckets = data.map { |item| { bucket: extract_type_name(item[:type]), count: item[:count] } }
      print_chart_with_title(buckets, "Volume de demandes par type", method: :format_volume_bar_chart)
    end

    def print_volume_by_provider
      data = @create_aggregator.volume_by_provider
      buckets = data.map { |item| { bucket: item[:provider], count: item[:count] } }
      print_chart_with_title(buckets, "Volume de demandes par fournisseur", method: :format_volume_bar_chart)
    end

    def print_volume_by_type_with_states
      data = @create_aggregator.volume_by_type_with_states
      items = data.map { |item| transform_state_data(item, extract_type_name(item[:type])) }
      print_chart_with_title(items, "Volume de demandes par type (validées vs refusées)", method: :format_split_bar_chart)
    end

    def print_volume_by_provider_with_states
      data = @create_aggregator.volume_by_provider_with_states
      items = data.map { |item| transform_state_data(item, item[:provider]) }
      print_chart_with_title(items, "Volume de demandes par fournisseur (validées vs refusées)", method: :format_split_bar_chart)
    end

    def print_median_time_to_submit_by_type
      data = @create_aggregator.median_time_to_submit_by_type
      return puts "\nAucune donnée disponible pour la durée médiane de soumission par type." if data.empty?

      puts "\n## Durée médiane de soumission par type pour #{human_readable_date_range}#{type_filter_label}:\n"

      one_hour = 3600.0
      under_one_hour = data.select { |item| item[:median_time] < one_hour }
      one_hour_or_more = data.select { |item| item[:median_time] >= one_hour }
      
      print_time_buckets('Moins d\'1 heure', under_one_hour, 60.0) if under_one_hour.any?
      print_time_buckets('1 heure ou plus', one_hour_or_more, 3600.0) if one_hour_or_more.any?
    end

    def print_median_time_to_first_instruction_by_type
      data = @create_aggregator.median_time_to_first_instruction_by_type
      return puts "\nAucune donnée disponible pour la durée médiane de première instruction par type." if data.empty?

      puts "\n## Durée médiane de première instruction par type pour #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      buckets = data.map { |item| transform_time_bucket(item, 86400.0) }
      
      puts "```"
      puts format_time_bar_chart(buckets, 'jours')
      puts "```"
    end

    def print_median_time_to_submit_by_provider
      data = @create_aggregator.median_time_to_submit_by_provider
      return puts "\nAucune donnée disponible pour la durée médiane de soumission par fournisseur." if data.empty?

      puts "\n## Durée médiane de soumission par fournisseur pour #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      buckets = data.map { |item| transform_time_bucket_by_provider(item, 60.0) }
      
      puts "```"
      puts format_time_bar_chart(buckets, 'minutes')
      puts "```"
    end

    def print_median_time_to_first_instruction_by_provider
      data = @create_aggregator.median_time_to_first_instruction_by_provider
      return puts "\nAucune donnée disponible pour la durée médiane de première instruction par fournisseur." if data.empty?

      puts "\n## Durée médiane de première instruction par fournisseur pour #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      buckets = data.map { |item| transform_time_bucket_by_provider(item, 86400.0) }
      
      puts "```"
      puts format_time_bar_chart(buckets, 'jours')
      puts "```"
    end

    def print_median_time_to_production_instruction_by_type
      return unless dgfip_report?
      
      data = @production_aggregator.median_time_to_production_instruction_by_type
      return puts "\nAucune donnée disponible pour la durée médiane de première instruction production par type." if data.empty?

      puts "\n## Durée médiane de première instruction production par type pour #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      buckets = data.map { |item| transform_time_bucket(item, 86400.0) }
      
      puts "```"
      puts format_time_bar_chart(buckets, 'jours')
      puts "```"
    end

    def print_time_to_production_instruction_by_duration(step: :day)
      return unless dgfip_report?
      
      buckets = @production_aggregator.time_to_production_instruction_by_duration_buckets(step: step)
      print_chart_with_title(buckets, "Durée de première instruction production par #{step_label_text(step)}", preposition: 'de')
    end

    private

    def format_metric(label, value)
      "#{label}: #{format_duration(value)}"
    end

    def extract_type_name(type)
      format_type_name(type.split('::').last)
    end

    def transform_state_data(item, label)
      {
        label: label,
        validated: item[:validated],
        refused: item[:refused],
        total: item[:total]
      }
    end

    def transform_time_bucket(item, divisor)
      {
        bucket: extract_type_name(item[:type]),
        value: (item[:median_time] / divisor).round(1),
        count: item[:count]
      }
    end

    def transform_time_bucket_by_provider(item, divisor)
      {
        bucket: item[:provider],
        value: (item[:median_time] / divisor).round(1),
        count: item[:count]
      }
    end

    def print_chart_with_title(data, title, method: :format_bar_chart, unit: nil, preposition: 'pour')
      return puts "\nAucune donnée disponible pour #{title.downcase}." if data.empty?

      puts "\n## #{title} #{preposition} #{human_readable_date_range}#{type_filter_label}:\n\n"
      puts "```"
      puts unit ? send(method, data, unit) : send(method, data)
      puts "```"
    end

    def print_time_buckets(title, data, divisor)
      puts "\n### #{title}:\n"
      
      buckets = data.map do |item|
        time_seconds = item[:median_time]
        {
          bucket: extract_type_name(item[:type]),
          value: (time_seconds / divisor).round(1),
          display_value: format_time_with_unit(time_seconds),
          count: item[:count]
        }
      end
      
      puts "```"
      puts format_time_bar_chart_with_labels(buckets)
      puts "```"
    end

    def build_bar_chart(items, value_key:, label_align:, unit: nil, show_count: false, display_value_key: nil)
      max_value = items.map { |item| item[value_key] }.max
      return "Aucune donnée" if max_value.nil? || max_value == 0

      max_bar_length = 50
      scale = max_value > max_bar_length ? (max_bar_length.to_f / max_value) : 1.0

      lines = build_chart_lines(items, value_key, label_align, scale, unit, show_count, display_value_key)
      lines += build_chart_footer(items, scale, unit, value_key)

      lines.join("\n")
    end

    def build_chart_lines(items, value_key, label_align, scale, unit, show_count, display_value_key)
      max_label_width = items.map { |item| item[:bucket]&.to_s&.length || item[:label]&.to_s&.length }.compact.max || 0
      max_value_width = items.map { |item| item[value_key].to_s.length }.max || 0
      max_display_width = display_value_key ? items.map { |item| item[display_value_key].to_s.length }.max : 0
      max_count_width = items.map { |item| (item[:count] || item[:total]).to_s.length }.max || 0

      items.map do |item|
        build_chart_line(item, value_key, label_align, scale, max_label_width, max_value_width, max_count_width, unit, show_count, display_value_key, max_display_width)
      end
    end

    def build_chart_line(item, value_key, label_align, scale, max_label_width, max_value_width, max_count_width, unit, show_count, display_value_key, max_display_width = 0)
      bar = "█" * (item[value_key] * scale).round
      label = (item[:bucket] || item[:label]).to_s.send(label_align, max_label_width)
      
      if item[:validated]
        build_split_bar_line(item, label, scale, max_label_width, max_count_width)
      elsif display_value_key
        display_value = item[display_value_key].to_s.rjust(max_display_width)
        count = item[:count].to_s.rjust(max_count_width)
        "#{label} (#{display_value}, n=#{count}) │ #{bar}"
      elsif show_count && unit
        value = item[value_key].to_s.rjust(max_value_width)
        count = item[:count].to_s.rjust(max_count_width)
        "#{label} (#{value} #{unit}, n=#{count}) │ #{bar}"
      else
        count = item[:count].to_s.rjust(max_count_width)
        "#{label} (#{count}) │ #{bar}"
      end
    end

    def build_split_bar_line(item, label, scale, max_label_width, max_count_width)
      validated_bar = "█" * (item[:validated] * scale).round
      refused_bar = "▓" * (item[:refused] * scale).round
      
      total = item[:total]
      validated_pct = total > 0 ? (item[:validated].to_f / total * 100).round(1) : 0
      refused_pct = total > 0 ? (item[:refused].to_f / total * 100).round(1) : 0
      
      total_str = total.to_s.rjust(max_count_width)
      "#{label} (#{total_str}: #{validated_pct.to_s.rjust(5)}%V #{refused_pct.to_s.rjust(5)}%R) │ #{validated_bar}#{refused_bar}"
    end

    def build_chart_footer(items, scale, unit, value_key)
      lines = [""]
      
      if items.first&.key?(:validated)
        lines << "Légende : █ = Validées, ▓ = Refusées"
        lines << "Total : #{items.sum { |i| i[:validated] }} validées, #{items.sum { |i| i[:refused] }} refusées (#{items.sum { |i| i[:total] }} total)"
      else
        lines << "Total : #{items.sum { |i| i[:count] }} demandes"
      end
      
      if scale < 1.0
        scale_label = unit ? "#{unit}" : "demande(s)"
        lines << "Échelle : chaque █ représente #{(1.0 / scale).round(1)} #{scale_label}"
      end
      
      lines
    end

    def authorization_requests_with_first_create_in_range
      first_create_events_subquery = Stats::Aggregator.new.first_create_events_subquery

      authorization_requests_with_type
        .joins("INNER JOIN (#{first_create_events_subquery.to_sql}) first_create_events ON first_create_events.authorization_request_id = authorization_requests.id")
        .where(first_create_events: { event_time: @date_range })
    end

    def authorization_requests_with_reopen_events_in_range
      reopen_events_subquery = AuthorizationRequestEvent
        .where(name: 'reopen')
        .where(created_at: @date_range)
        .select('DISTINCT authorization_request_id')

      authorization_requests_with_type
        .where(id: reopen_events_subquery)
    end

    def authorization_requests_with_start_next_stage_events_in_range
      start_next_stage_events_subquery = AuthorizationRequestEvent
        .where(name: 'start_next_stage')
        .where(created_at: @date_range)
        .select('DISTINCT authorization_request_id')

      authorization_requests_with_type
        .where(id: start_next_stage_events_subquery)
    end

    def authorization_requests_with_approve_events_in_range
      approve_events_subquery = AuthorizationRequestEvent
        .where(name: 'approve')
        .where(created_at: @date_range)
        .select('DISTINCT authorization_request_id')

      authorization_requests_with_type
        .where(id: approve_events_subquery)
    end

    def authorization_requests_with_refuse_events_in_range
      refuse_events_subquery = AuthorizationRequestEvent
        .where(name: 'refuse')
        .where(created_at: @date_range)
        .select('DISTINCT authorization_request_id')

      authorization_requests_with_type
        .where(id: refuse_events_subquery)
    end

  def authorization_requests_with_type
    base_scope = if @authorization_types.present?
      AuthorizationRequest.where(type: @authorization_types)
    else
      AuthorizationRequest.all
    end
    
    # Exclude dirty_from_v1 authorization requests as they have inconsistent event data from migration
    base_scope.where(dirty_from_v1: false)
  end

    def authorization_types_from_provider
      return nil unless @provider.present?
      
      data_provider = DataProvider.friendly.find(@provider)
      data_provider.authorization_definitions.map(&:authorization_request_class_as_string)
    rescue ActiveRecord::RecordNotFound
      raise "Provider not found: #{@provider}"
    end

    def human_readable_date_range
      if date_range_is_a_year(@date_input)
        @date_input
      else
        "#{@date_input.first.strftime('%d/%m/%Y')} - #{@date_input.last.strftime('%d/%m/%Y')}"
      end
    end

    def type_filter_label
      return "" unless @authorization_types.present?
      
      if @provider.present?
        " (fournisseur : #{@provider})"
      else
        type_names = @authorization_types.map do |type|
          format_type_name(type.split('::').last)
        end
        
        " (types par : #{type_names.join(', ')})"
      end
    end

    def format_type_name(type_name)
      # Return type name as-is without adding spaces
      type_name
    end

    def date_range_is_a_year(date_range)
      date_range.is_a?(Integer) && date_range > 2000
    end

    def extract_date_range(date_range)
      if date_range_is_a_year(date_range)
        Date.new(date_range).all_year
      elsif date_range.is_a?(Range)
        date_range
      else
        raise "Invalid date range: #{date_range}"
      end
    end

    def format_duration(seconds)
      return 'N/A' if seconds.nil?
      
      seconds = seconds.to_f
      distance_of_time_in_words(Time.now, Time.now + seconds.seconds)
    end

    def format_table_header
      format("%-50s | %5s | %20s | %20s | %20s", "Type", "Nombre", "Min", "Moy", "Max")
    end

    def format_table_separator(stats)
      return "-" * 120 if stats.any?
      "-" * 120
    end

    def format_table_row(stat)
      # Extract the class name without namespace and format it
      type_name = stat[:type].split('::').last
      # Add space before capitals but preserve consecutive capitals (acronyms)
      type_name = type_name.gsub(/([a-z])([A-Z])/, '\1 \2')
      
      format(
        "%-50s | %5d | %20s | %20s | %20s",
        type_name,
        stat[:count],
        format_duration(stat[:min_time]),
        format_duration(stat[:avg_time]),
        format_duration(stat[:max_time])
      )
    end

    def step_label_text(step)
      case step
      when :minute
        "minute"
      when :hour
        "heure"
      when :day
        "jour"
      else
        step.to_s
      end
    end

    def format_bar_chart(buckets, step = nil)
      build_bar_chart(buckets, value_key: :count, label_align: :rjust)
    end

    def format_volume_bar_chart(buckets)
      build_bar_chart(buckets, value_key: :count, label_align: :ljust)
    end

    def format_split_bar_chart(items)
      max_total = items.map { |i| i[:total] }.max
      return "Aucune donnée" if max_total == 0
      
      # Calculate bar scale - aim for max bar length of 50 characters
      max_bar_length = 50
      scale = max_total > max_bar_length ? (max_bar_length.to_f / max_total) : 1.0
      
      lines = []
      
      # Find the maximum width needed for labels
      max_label_width = items.map { |i| i[:label].to_s.length }.max
      max_total_width = items.map { |i| i[:total].to_s.length }.max
      
      # Build bars with total count and percentages
      items.each do |item|
        validated_length = (item[:validated] * scale).round
        refused_length = (item[:refused] * scale).round
        
        validated_bar = "█" * validated_length
        refused_bar = "▓" * refused_length
        
        # Calculate percentages
        total = item[:total]
        validated_pct = total > 0 ? (item[:validated].to_f / total * 100).round(1) : 0
        refused_pct = total > 0 ? (item[:refused].to_f / total * 100).round(1) : 0
        
        label = item[:label].to_s.ljust(max_label_width)
        total_str = total.to_s.rjust(max_total_width)
        
        lines << "#{label} (#{total_str}: #{validated_pct.to_s.rjust(5)}%V #{refused_pct.to_s.rjust(5)}%R) │ #{validated_bar}#{refused_bar}"
      end
      
      lines << ""
      lines << "Légende : █ = Validées, ▓ = Refusées"
      lines << "Total : #{items.sum { |i| i[:validated] }} validées, #{items.sum { |i| i[:refused] }} refusées (#{items.sum { |i| i[:total] }} total)"
      lines << "Échelle : chaque caractère représente #{(1.0 / scale).round(1)} demande(s)" if scale < 1.0
      
      lines.join("\n")
    end

    def format_time_bar_chart(buckets, unit)
      build_bar_chart(buckets, value_key: :value, label_align: :ljust, unit: unit, show_count: true)
    end

    def format_time_with_unit(seconds)
      if seconds < 3600
        minutes = (seconds / 60.0).round(1)
        "#{minutes} #{"minute".pluralize(minutes)}"
      elsif seconds < 86400
        hours = (seconds / 3600.0).round(1)
        "#{hours} #{"hour".pluralize(hours)}"
      else
        days = (seconds / 86400.0).round(1)
        "#{days} #{"day".pluralize(days)}"
      end
    end

    def format_time_bar_chart_with_labels(buckets)
      build_bar_chart(buckets, value_key: :value, label_align: :ljust, display_value_key: :display_value, show_count: true)
    end
  end
end