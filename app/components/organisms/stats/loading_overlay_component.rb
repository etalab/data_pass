class Organisms::Stats::LoadingOverlayComponent < ApplicationComponent
  def initialize(stimulus_controller: 'stats')
    @stimulus_controller = stimulus_controller
  end

  attr_reader :stimulus_controller
end
