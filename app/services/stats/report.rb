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
    end

    def print_report
      result =  " \n# Report of #{human_readable_date_range}#{type_filter_label}:\n\n"
      result += "#{number_of_authorization_requests_created}\n"
      result += "#{number_of_reopen_events}\n"
      result += "\n"
      result += "#{average_time_to_submit}\n#{median_time_to_submit}\n#{mode_time_to_submit}\n#{stddev_time_to_submit}\n"
      result += "\n"
      result += "#{average_time_to_first_instruction}\n#{median_time_to_first_instruction}\n#{mode_time_to_first_instruction}\n#{stddev_time_to_first_instruction}\n"
      puts result
    end

    def number_of_authorization_requests_created
      "#{@authorization_requests_created_in_range.count} authorization requests created"
    end

    def number_of_reopen_events
      "#{@reopen_aggregator.reopen_events_count} reopen events"
    end

    def average_time_to_submit
      "Average time to submit: #{format_duration(@create_aggregator.average_time_to_submit)}"
    end

    def median_time_to_submit
      "Median time to submit: #{format_duration(@create_aggregator.median_time_to_submit)}"
    end

    def stddev_time_to_submit
      "Standard deviation time to submit: #{format_duration(@create_aggregator.stddev_time_to_submit)}"
    end

    def mode_time_to_submit
      "Mode time to submit: #{format_duration(@create_aggregator.mode_time_to_submit)}"
    end

    def average_time_to_first_instruction
      "Average time to first instruction: #{format_duration(@create_aggregator.average_time_to_first_instruction)}"
    end

    def median_time_to_first_instruction
      "Median time to first instruction: #{format_duration(@create_aggregator.median_time_to_first_instruction)}"
    end

    def stddev_time_to_first_instruction
      "Standard deviation time to first instruction: #{format_duration(@create_aggregator.stddev_time_to_first_instruction)}"
    end

    def mode_time_to_first_instruction
      "Mode time to first instruction: #{format_duration(@create_aggregator.mode_time_to_first_instruction)}"
    end

    def print_time_to_submit_by_type_table
      stats = @create_aggregator.time_to_submit_by_type
      
      if stats.empty?
        puts "\nNo data available for statistics by type."
        return
      end

      puts "\n# Time to submit by Authorization Request Type of #{human_readable_date_range}#{type_filter_label}:\n\n"
      puts format_table_header
      puts format_table_separator(stats)
      
      stats.each do |stat|
        puts format_table_row(stat)
      end
    end

    def time_to_submit_by_type_table
      stats = @create_aggregator.time_to_submit_by_type
      return "No data available" if stats.empty?

      lines = []
      lines << format_table_header
      lines << format_table_separator(stats)
      stats.each { |stat| lines << format_table_row(stat) }
      lines.join("\n")
    end

    def print_time_to_submit_by_duration(step: :day)
      buckets = @create_aggregator.time_to_submit_by_duration_buckets(step: step)
      
      if buckets.empty? || buckets.sum { |b| b[:count] } == 0
        puts "\nNo data available for time to submit by duration."
        return
      end

      step_label = step_label_text(step)
      puts "\n# Time to submit by #{step_label} of #{human_readable_date_range}#{type_filter_label}:\n\n"
      puts "```"
      puts format_bar_chart(buckets, step)
      puts "```"
    end

    def print_time_to_first_instruction_by_duration(step: :day)
      buckets = @create_aggregator.time_to_first_instruction_by_duration_buckets(step: step)
      
      if buckets.empty? || buckets.sum { |b| b[:count] } == 0
        puts "\nNo data available for time to first instruction by duration."
        return
      end

      step_label = step_label_text(step)
      puts "\n# Time to first instruction by #{step_label} of #{human_readable_date_range}#{type_filter_label}:\n\n"
      puts "```"
      puts format_bar_chart(buckets, step)
      puts "```"
    end

    def print_volume_by_type
      data = @create_aggregator.volume_by_type
      
      if data.empty?
        puts "\nNo data available for volume by type."
        return
      end

      puts "\n# Volume of authorization requests by type for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for bar chart
      buckets = data.map { |item| { bucket: format_type_name(item[:type].split('::').last), count: item[:count] } }
      puts "```"
      puts format_volume_bar_chart(buckets)
      puts "```"
    end

    def print_volume_by_provider
      data = @create_aggregator.volume_by_provider
      
      if data.empty?
        puts "\nNo data available for volume by provider."
        return
      end

      puts "\n# Volume of authorization requests by provider for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for bar chart
      buckets = data.map { |item| { bucket: item[:provider], count: item[:count] } }
      puts "```"
      puts format_volume_bar_chart(buckets)
      puts "```"
    end

    def print_volume_by_type_with_states
      data = @create_aggregator.volume_by_type_with_states
      
      if data.empty?
        puts "\nNo data available for volume by type with states."
        return
      end

      puts "\n# Volume of authorization requests by type (validated vs refused) for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for split bar chart
      items = data.map do |item|
        {
          label: format_type_name(item[:type].split('::').last),
          validated: item[:validated],
          refused: item[:refused],
          total: item[:total]
        }
      end
      puts "```"
      puts format_split_bar_chart(items)
      puts "```"
    end

    def print_volume_by_provider_with_states
      data = @create_aggregator.volume_by_provider_with_states
      
      if data.empty?
        puts "\nNo data available for volume by provider with states."
        return
      end

      puts "\n# Volume of authorization requests by provider (validated vs refused) for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for split bar chart
      items = data.map do |item|
        {
          label: item[:provider],
          validated: item[:validated],
          refused: item[:refused],
          total: item[:total]
        }
      end
      puts "```"
      puts format_split_bar_chart(items)
      puts "```"
    end

    def print_median_time_to_submit_by_type
      data = @create_aggregator.median_time_to_submit_by_type
      
      if data.empty?
        puts "\nNo data available for median time to submit by type."
        return
      end

      puts "\n# Median time to submit by type for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for bar chart - convert seconds to human readable
      max_time = data.map { |item| item[:median_time] }.max
      median_time = data.map { |item| item[:median_time] }.sort[data.length / 2]
      
      # Find appropriate unit based on median rather than max to avoid outlier bias
      unit, divisor = if median_time > 2 * 86400
        ["days", 86400.0]
      elsif median_time > 90 * 60
        ["hours", 3600.0]
      else
        ["minutes", 60.0]
      end
      
      buckets = data.map do |item|
        {
          bucket: format_type_name(item[:type].split('::').last),
          value: (item[:median_time] / divisor).round(1),
          count: item[:count]
        }
      end
      
      puts "```"
      puts format_time_bar_chart(buckets, unit)
      puts "```"
    end

    def print_median_time_to_first_instruction_by_type
      data = @create_aggregator.median_time_to_first_instruction_by_type
      
      if data.empty?
        puts "\nNo data available for median time to first instruction by type."
        return
      end

      puts "\n# Median time to first instruction by type for #{human_readable_date_range}#{type_filter_label}:\n\n"
      
      # Format data for bar chart - convert seconds to human readable
      max_time = data.map { |item| item[:median_time] }.max
      median_time = data.map { |item| item[:median_time] }.sort[data.length / 2]
      
      # Find appropriate unit based on median rather than max to avoid outlier bias
      unit, divisor = if median_time > 2 * 86400
        ["days", 86400.0]
      elsif median_time > 90 * 60
        ["hours", 3600.0]
      else
        ["minutes", 60.0]
      end
      
      buckets = data.map do |item|
        {
          bucket: format_type_name(item[:type].split('::').last),
          value: (item[:median_time] / divisor).round(1),
          count: item[:count]
        }
      end
      
      puts "```"
      puts format_time_bar_chart(buckets, unit)
      puts "```"
    end

    private

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
        " (provider: #{@provider})"
      else
        type_names = @authorization_types.map do |type|
          format_type_name(type.split('::').last)
        end
        
        " (types by: #{type_names.join(', ')})"
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
      format("%-50s | %5s | %20s | %20s | %20s", "Type", "Count", "Min", "Avg", "Max")
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
        "hour"
      when :day
        "day"
      else
        step.to_s
      end
    end

    def format_bar_chart(buckets, step)
      max_count = buckets.map { |b| b[:count] }.max
      return "No data" if max_count == 0
      
      # Calculate bar scale - aim for max bar length of 50 characters
      max_bar_length = 50
      scale = max_count > max_bar_length ? (max_bar_length.to_f / max_count) : 1.0
      
      lines = []
      
      # Find the maximum width needed for bucket labels and counts
      max_label_width = buckets.map { |b| b[:bucket].to_s.length }.max
      max_count_width = buckets.map { |b| b[:count].to_s.length }.max
      
      # Build bars with counts on the left
      buckets.each do |bucket|
        bar_length = (bucket[:count] * scale).round
        bar = "█" * bar_length
        label = bucket[:bucket].to_s.rjust(max_label_width)
        count = bucket[:count].to_s.rjust(max_count_width)
        lines << "#{label} (#{count}) │ #{bar}"
      end
      
      lines << ""
      lines << "Total: #{buckets.sum { |b| b[:count] }} authorization requests"
      lines << "Scale: each █ represents #{(1.0 / scale).round(1)} request(s)" if scale < 1.0
      
      lines.join("\n")
    end

    def format_volume_bar_chart(buckets)
      max_count = buckets.map { |b| b[:count] }.max
      return "No data" if max_count == 0
      
      # Calculate bar scale - aim for max bar length of 50 characters
      max_bar_length = 50
      scale = max_count > max_bar_length ? (max_bar_length.to_f / max_count) : 1.0
      
      lines = []
      
      # Find the maximum width needed for labels and counts
      max_label_width = buckets.map { |b| b[:bucket].to_s.length }.max
      max_count_width = buckets.map { |b| b[:count].to_s.length }.max
      
      # Build bars with counts on the left
      buckets.each do |bucket|
        bar_length = (bucket[:count] * scale).round
        bar = "█" * bar_length
        label = bucket[:bucket].to_s.ljust(max_label_width)
        count = bucket[:count].to_s.rjust(max_count_width)
        lines << "#{label} (#{count}) │ #{bar}"
      end
      
      lines << ""
      lines << "Total: #{buckets.sum { |b| b[:count] }} authorization requests"
      lines << "Scale: each █ represents #{(1.0 / scale).round(1)} request(s)" if scale < 1.0
      
      lines.join("\n")
    end

    def format_split_bar_chart(items)
      max_total = items.map { |i| i[:total] }.max
      return "No data" if max_total == 0
      
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
      lines << "Legend: █ = Validated, ▓ = Refused"
      lines << "Total: #{items.sum { |i| i[:validated] }} validated, #{items.sum { |i| i[:refused] }} refused (#{items.sum { |i| i[:total] }} total)"
      lines << "Scale: each character represents #{(1.0 / scale).round(1)} request(s)" if scale < 1.0
      
      lines.join("\n")
    end

    def format_time_bar_chart(buckets, unit)
      max_value = buckets.map { |b| b[:value] }.max
      return "No data" if max_value == 0
      
      # Calculate bar scale - aim for max bar length of 50 characters
      max_bar_length = 50
      scale = max_value > max_bar_length ? (max_bar_length.to_f / max_value) : 1.0
      
      lines = []
      
      # Find the maximum width needed for labels and values
      max_label_width = buckets.map { |b| b[:bucket].to_s.length }.max
      max_value_width = buckets.map { |b| b[:value].to_s.length }.max
      max_count_width = buckets.map { |b| b[:count].to_s.length }.max
      
      # Build bars with values on the left
      buckets.each do |bucket|
        bar_length = (bucket[:value] * scale).round
        bar = "█" * bar_length
        label = bucket[:bucket].to_s.ljust(max_label_width)
        value = bucket[:value].to_s.rjust(max_value_width)
        count = bucket[:count].to_s.rjust(max_count_width)
        lines << "#{label} (#{value} #{unit}, n=#{count}) │ #{bar}"
      end
      
      lines << ""
      lines << "Total: #{buckets.sum { |b| b[:count] }} authorization requests"
      lines << "Scale: each █ represents #{(1.0 / scale).round(1)} #{unit}" if scale < 1.0
      
      lines.join("\n")
    end
  end
end