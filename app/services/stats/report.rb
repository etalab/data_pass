module Stats
  class Report
    include ActionView::Helpers::DateHelper

    def initialize(date_input: 2025)
      @date_input = date_input
      @date_range = extract_date_range(date_input)
      @authorization_requests_created_in_range = authorization_requests_with_first_create_in_range
      @aggregator = Stats::Aggregator.new(@authorization_requests_created_in_range)
    end

    def print_report
      puts "# Report of #{human_readable_date_range}:\n\n#{min_time_to_submit}\n#{average_time_to_submit}\n#{max_time_to_submit}"
    end

    def average_time_to_submit
      "Average time to submit: #{format_duration(@aggregator.average_time_to_submit)}"
    end

    def min_time_to_submit
      "Min time to submit: #{format_duration(@aggregator.min_time_to_submit)}"
    end

    def max_time_to_submit
      "Max time to submit: #{format_duration(@aggregator.max_time_to_submit)}"
    end

    def print_time_to_submit_by_type_table
      stats = @aggregator.time_to_submit_by_type
      
      if stats.empty?
        puts "\nNo data available for statistics by type."
        return
      end

      puts "\n# Time to submit by Authorization Request Type of #{human_readable_date_range}:\n\n"
      puts format_table_header
      puts format_table_separator(stats)
      
      stats.each do |stat|
        puts format_table_row(stat)
      end
    end

    def time_to_submit_by_type_table
      stats = @aggregator.time_to_submit_by_type
      return "No data available" if stats.empty?

      lines = []
      lines << format_table_header
      lines << format_table_separator(stats)
      stats.each { |stat| lines << format_table_row(stat) }
      lines.join("\n")
    end

    private

    def authorization_requests_with_first_create_in_range
      first_create_events_subquery = Stats::Aggregator.new.first_create_events_subquery

      AuthorizationRequest
        .joins("INNER JOIN (#{first_create_events_subquery.to_sql}) first_create_events ON first_create_events.authorization_request_id = authorization_requests.id")
        .where("first_create_events.event_time >= ? AND first_create_events.event_time <= ?", @date_range.first.beginning_of_day, @date_range.last.end_of_day)
    end

    def human_readable_date_range
      if date_range_is_a_year(@date_input)
        @date_input
      else
        "#{@date_input.first.strftime('%d/%m/%Y')} - #{@date_input.last.strftime('%d/%m/%Y')}"
      end
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
  end
end

# [2025, 2024, 2023].each{ |year| Stats::Report.new(date_input: year).print_report }; puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_type_table; puts 'ok'