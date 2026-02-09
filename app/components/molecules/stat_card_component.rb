class Molecules::StatCardComponent < ApplicationComponent
  def initialize(title:, target:, style:, stimulus_controller: 'stats', subtitle_target: nil)
    @title = title
    @target = target
    @card_classes = style[:card_classes]
    @value_classes = style[:value_classes]
    @col_classes = style[:col_classes]
    @stimulus_controller = stimulus_controller
    @subtitle_target = subtitle_target
  end

  attr_reader :title, :target, :card_classes, :value_classes, :col_classes,
    :stimulus_controller, :subtitle_target

  def subtitle?
    subtitle_target.present?
  end

  def value_mb_class
    subtitle? ? 'fr-mb-1v' : 'fr-mb-0'
  end
end
