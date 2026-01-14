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
      result += "#{average_time_to_submit}\n#{median_time_to_submit}\n#{stddev_time_to_submit}\n"
      result += "\n"
      result += "#{average_time_to_first_instruction}\n#{median_time_to_first_instruction}\n#{stddev_time_to_first_instruction}\n"
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

    def average_time_to_first_instruction
      "Average time to first instruction: #{format_duration(@create_aggregator.average_time_to_first_instruction)}"
    end

    def median_time_to_first_instruction
      "Median time to first instruction: #{format_duration(@create_aggregator.median_time_to_first_instruction)}"
    end

    def stddev_time_to_first_instruction
      "Standard deviation time to first instruction: #{format_duration(@create_aggregator.stddev_time_to_first_instruction)}"
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
      puts format_bar_chart(buckets, step)
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
      if @authorization_types.present?
        AuthorizationRequest.where(type: @authorization_types)
      else
        AuthorizationRequest.all
      end
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
      # Add space before capitals but preserve consecutive capitals (acronyms)
      type_name.gsub(/([a-z])([A-Z])/, '\1 \2')
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
  end
end

# [2025, 2024, 2023].each{ |year| Stats::Report.new(date_input: year).print_report }; puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_type_table; puts 'ok'

# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :day); puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :hour); puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :minute); puts 'ok'

# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier']).print_report; puts 'ok'
# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']).print_time_to_submit_by_duration(step: :day); puts 'ok'
# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier']).print_time_to_submit_by_duration(step: :minute); puts 'ok'

# Stats::Report.new(date_input: 2025, provider: 'dinum').print_report; puts 'ok'
# Stats::Report.new(date_input: 2025, provider: 'dgfip').print_time_to_submit_by_duration(step: :day); puts 'ok'
