class TinyAlertComponent < ApplicationComponent
  VALID_TYPES = %i[success info warning error].freeze

  def initialize(type:, message:, dismissible: true)
    @type = type.to_sym
    @message = message
    @dismissible = dismissible
    super()
  end

  def before_render
    raise ArgumentError, "Invalid type: #{@type}" unless VALID_TYPES.include?(@type)
  end

  def alert_classes
    "fr-alert fr-alert--#{@type} fr-alert--sm fr-alert--tiny"
  end

  attr_reader :message, :dismissible

  def dismissible?
    @dismissible
  end
end
