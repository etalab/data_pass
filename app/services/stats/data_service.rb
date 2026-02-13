class Stats::DataService
  def initialize(date_range:, providers: nil, authorization_types: nil, forms: nil)
    @date_range = date_range
    @providers = providers
    @authorization_types = authorization_types
    @forms = forms
  end

  def call
    {
      volume: volume_data,
      time_series: backlog_evolution_data,
      durations: {
        time_to_submit: time_to_submit_data,
        time_to_first_instruction: time_to_first_instruction_data,
        time_to_final_instruction: time_to_final_instruction_data
      }
    }
  end

  private

  def query_filters
    @query_filters ||= {
      date_range: @date_range,
      providers: @providers,
      authorization_types: @authorization_types,
      forms: @forms
    }
  end

  def volume_data
    query = Stats::VolumeStatsQuery.new(**query_filters)
    {
      total_requests_submitted: query.total_requests_submitted_count,
      new_requests_submitted: query.new_requests_submitted_count,
      reopenings_submitted: query.reopenings_submitted_count,
      validations: query.validations_count,
      refusals: query.refusals_count
    }
  end

  def time_series_result
    @time_series_result ||= Stats::TimeSeriesQuery.new(**query_filters).time_series_data
  end

  def backlog_evolution_data
    backlog_query = Stats::BacklogEvolutionQuery.new(**query_filters)

    periods = time_series_result[:data].pluck(:period)
    backlog_by_period = backlog_query.calculate_backlog_for_periods(periods)

    merged_data = time_series_result[:data].map do |ts_data|
      ts_data.merge(backlog: backlog_by_period[ts_data[:period]] || 0)
    end

    {
      unit: time_series_result[:unit],
      data: merged_data
    }
  end

  def time_to_submit_data
    percentiles_to_hash(Stats::TimeToSubmitQuery.new(**query_filters).percentiles)
  end

  def time_to_first_instruction_data
    percentiles_to_hash(Stats::TimeToFirstInstructionQuery.new(**query_filters).percentiles)
  end

  def time_to_final_instruction_data
    percentiles_to_hash(Stats::TimeToFinalInstructionQuery.new(**query_filters).percentiles)
  end

  def percentiles_to_hash(percentiles)
    {
      percentile_50_seconds: percentiles[:p50],
      percentile_80_seconds: percentiles[:p80]
    }
  end
end
