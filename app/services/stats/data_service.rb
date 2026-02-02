module Stats
  class DataService
    def initialize(date_range:, providers: nil, authorization_types: nil, forms: nil)
      @date_range = date_range
      @providers = providers
      @authorization_types = authorization_types
      @forms = forms
    end

    def call
      {
        filters: filters_data,
        dimension: determine_dimension,
        volume: volume_data,
        durations: {
          time_to_submit: time_to_submit_data,
          time_to_first_instruction: time_to_first_instruction_data,
          time_to_final_instruction: time_to_final_instruction_data
        },
        breakdowns: breakdown_data
      }
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

    def time_to_submit_data
      query = Stats::TimeToSubmitQuery.new(**query_filters)
      {
        median_seconds: query.median&.to_f,
        stddev_seconds: query.stddev&.to_f
      }
    end

    def time_to_first_instruction_data
      query = Stats::TimeToFirstInstructionQuery.new(**query_filters)
      {
        median_seconds: query.median&.to_f,
        stddev_seconds: query.stddev&.to_f
      }
    end

    def time_to_final_instruction_data
      query = Stats::TimeToFinalInstructionQuery.new(**query_filters)
      {
        median_seconds: query.median&.to_f,
        stddev_seconds: query.stddev&.to_f
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
