class Organisms::Stats::TimeSeriesChartComponent < ApplicationComponent
  def initialize(stimulus_controller: 'stats')
    @stimulus_controller = stimulus_controller
  end

  attr_reader :stimulus_controller
end
