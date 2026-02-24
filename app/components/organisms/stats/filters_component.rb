class Organisms::Stats::FiltersComponent < ApplicationComponent
  def initialize(stimulus_controller: 'stats')
    @stimulus_controller = stimulus_controller
  end

  attr_reader :stimulus_controller

  def last_year
    Date.current.year - 1
  end

  def two_years_ago
    Date.current.year - 2
  end
end
