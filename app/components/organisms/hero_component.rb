class Organisms::HeroComponent < ApplicationComponent
  VARIANTS = %i[band blue].freeze

  renders_one :lead
  renders_one :actions
  renders_one :illustration
  renders_one :footer

  def initialize(title:, variant: :band, kicker: nil, heading: {}, section: {})
    raise ArgumentError, "variant must be one of #{VARIANTS.join(', ')}" if VARIANTS.exclude?(variant)

    @title = title
    @variant = variant
    @kicker = kicker
    @title_tag = heading.fetch(:tag, :h2)
    @title_class = heading[:class]
    @title_id = heading[:id]
    @section_id = section[:id]
    @section_class = section[:class]
  end

  attr_reader :title, :kicker, :title_tag, :title_class, :title_id, :section_id

  def blue?
    @variant == :blue
  end

  def section_classes
    variant_classes = blue? ? %w[lp-hero] : %w[lp-band]
    [*variant_classes, @section_class].compact.join(' ')
  end
end
