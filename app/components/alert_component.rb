class AlertComponent < ApplicationComponent
  VALID_TYPES = %i[success info warning error].freeze

  def initialize(type:, title:, description: nil, messages: [], close_button: true)
    @type = type.to_sym
    @title = title
    @description = description
    @messages = Array(messages).compact
    @close_button = close_button
    super()
  end

  def before_render
    raise ArgumentError, "Invalid type: #{@type}" unless VALID_TYPES.include?(@type)
  end

  def alert_classes
    "fr-alert fr-alert--#{@type} fr-my-8v"
  end

  attr_reader :title, :description, :messages

  def close_button?
    @close_button
  end
end
