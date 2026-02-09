class Molecules::DurationCardComponent < ApplicationComponent
  def initialize(
    title:,
    percentile_50_target:,
    percentile_80_target:,
    stimulus_controller: 'stats',
    type: :duration
  )
    @title = title
    @percentile_50_target = percentile_50_target
    @percentile_80_target = percentile_80_target
    @stimulus_controller = stimulus_controller
    @type = type
  end

  attr_reader :title, :percentile_50_target, :percentile_80_target, :stimulus_controller, :type

  def percentile_text
    type == :delay ? t('stats.durations.within') : t('stats.durations.less_than')
  end
end
