class Atoms::ConfigBlockComponent < ApplicationComponent
  def initialize(rows:)
    @rows = rows
  end

  private

  attr_reader :rows

  def boolean_row(label, value)
    badge_class = value ? 'config-block__badge--success' : 'config-block__badge--neutral'

    { label:, value: tag.span(boolean_label(value), class: "config-block__badge #{badge_class}") }
  end

  def boolean_label(value)
    value ? I18n.t('atoms.config_block_component.true') : I18n.t('atoms.config_block_component.false')
  end

  def title
    I18n.t('atoms.config_block_component.title')
  end
end
