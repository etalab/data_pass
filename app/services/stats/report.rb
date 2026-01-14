module Stats
  class Report
    include ActionView::Helpers::DateHelper

    def initialize
      @aggregator = Stats::Aggregator.new
    end

    def print_report
      puts "# Report:\n\n#{time_to_submit}\n#{min_time_to_submit}\n#{max_time_to_submit}"
    end

    def time_to_submit
      "Average time to submit: #{format_duration(@aggregator.time_to_submit)}"
    end

    def min_time_to_submit
      "Min time to submit: #{format_duration(@aggregator.min_time_to_submit)}"
    end

    def max_time_to_submit
      "Max time to submit: #{format_duration(@aggregator.max_time_to_submit)}"
    end

    private

    def format_duration(seconds)
      return 'N/A' if seconds.nil?
      
      seconds = seconds.to_f
      distance_of_time_in_words(Time.now, Time.now + seconds.seconds)
    end
  end
end

Stats::Report.new.print_report