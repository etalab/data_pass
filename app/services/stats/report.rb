module Stats
  class Report
    include ActionView::Helpers::DateHelper

    def initialize(date_range: 2025)
      @date_range = extract_date_range(date_range)
      @authorization_requests_created_in_range = authorization_requests_with_first_create_in_range
      @aggregator = Stats::Aggregator.new(@authorization_requests_created_in_range)
    end

    def print_report
      puts "# Report of #{human_readable_date_range}:\n\n#{average_time_to_submit}\n#{min_time_to_submit}\n#{max_time_to_submit}"
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

    private

    def authorization_requests_with_first_create_in_range
      first_create_events_subquery = Stats::Aggregator.new.first_create_events_subquery

      AuthorizationRequest
        .joins("INNER JOIN (#{first_create_events_subquery.to_sql}) first_create_events ON first_create_events.authorization_request_id = authorization_requests.id")
        .where("first_create_events.event_time >= ? AND first_create_events.event_time <= ?", @date_range.first.beginning_of_day, @date_range.last.end_of_day)
    end

    def human_readable_date_range
      if date_range_is_a_year(@date_range)
        @date_range
      else
        "#{@date_range.first.strftime('%d/%m/%Y')} - #{@date_range.last.strftime('%d/%m/%Y')}"
      end
    end

    def date_range_is_a_year(date_range)
      date_range.is_a?(Integer) and date_range > 2000
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
  end
end

Stats::Report.new(date_range: 2025).print_report