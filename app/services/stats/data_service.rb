module Stats
  class DataService
    def initialize(date_range:, providers: nil, authorization_types: nil, forms: nil, include_breakdowns: true)
      @date_range = date_range
      @providers = providers
      @authorization_types = authorization_types
      @forms = forms
      @include_breakdowns = include_breakdowns
    end

    def call
      result = {
        filters: filters_data,
        dimension: determine_dimension,
        volume: volume_data,
        time_series: backlog_evolution_data,
        durations: {
          time_to_submit: time_to_submit_data,
          time_to_first_instruction: time_to_first_instruction_data,
          time_to_final_instruction: time_to_final_instruction_data
        }
      }

      result[:breakdowns] = breakdown_data if @include_breakdowns

      result
    end

    private

    def filters_data
      {
        providers: @providers,
        authorization_types: @authorization_types,
        forms: @forms
      }
    end

    def determine_dimension
      return 'form' if single_selection?(@authorization_types) || multiple_selection?(@forms)
      return 'type' if single_selection?(@providers) || multiple_selection?(@authorization_types)

      'provider'
    end

    def single_selection?(collection)
      collection&.size == 1
    end

    def multiple_selection?(collection)
      collection && collection.size > 1
    end

    def query_filters
      {
        date_range: @date_range,
        providers: @providers,
        authorization_types: @authorization_types,
        forms: @forms
      }
    end

    def volume_data
      query = Stats::VolumeStatsQuery.new(**query_filters)
      {
        new_requests_submitted: query.new_requests_submitted_count,
        reopenings_submitted: query.reopenings_submitted_count,
        validations: query.validations_count,
        refusals: query.refusals_count
      }
    end

    def time_series_data
      query = Stats::TimeSeriesQuery.new(**query_filters)
      query.time_series_data
    end

    def backlog_evolution_data
      time_series = Stats::TimeSeriesQuery.new(**query_filters).time_series_data
      backlog_query = Stats::BacklogEvolutionQuery.new(**query_filters)

      merged_data = time_series[:data].map do |ts_data|
        period_date = Date.parse(ts_data[:period])
        period_end = period_date.end_of_day

        ts_data.merge(backlog: backlog_query.send(:calculate_backlog_at, period_end))
      end

      {
        unit: time_series[:unit],
        data: merged_data
      }
    end

    def time_to_submit_data
      query = Stats::TimeToSubmitQuery.new(**query_filters)
      {
        percentile_50_seconds: query.percentile_50&.to_f,
        percentile_90_seconds: query.percentile_90&.to_f
      }
    end

    def time_to_first_instruction_data
      query = Stats::TimeToFirstInstructionQuery.new(**query_filters)
      {
        percentile_50_seconds: query.percentile_50&.to_f,
        percentile_90_seconds: query.percentile_90&.to_f
      }
    end

    def time_to_final_instruction_data
      query = Stats::TimeToFinalInstructionQuery.new(**query_filters)
      {
        percentile_50_seconds: query.percentile_50&.to_f,
        percentile_90_seconds: query.percentile_90&.to_f
      }
    end

    def breakdown_data
      query = Stats::BreakdownStatsQuery.new(**query_filters)
      dimension = determine_dimension

      {
        volume: case dimension
                when 'provider'
                  query.volume_breakdown_by_provider
                when 'type'
                  query.volume_breakdown_by_type
                when 'form'
                  query.volume_breakdown_by_form
                end,
        time_to_submit: query.time_to_submit_breakdown(dimension),
        time_to_first_instruction: query.time_to_first_instruction_breakdown(dimension),
        time_to_final_instruction: query.time_to_final_instruction_breakdown(dimension)
      }
    end
  end
end
