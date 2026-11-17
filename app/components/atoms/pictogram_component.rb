class Atoms::PictogramComponent < ApplicationComponent
  LAYERS = %w[decorative minor major].freeze
  BACKGROUND_LAYERS = %w[motif background].freeze
  BACKGROUNDS = %w[ovoid].freeze

  def initialize(name:, size: 80, background: nil)
    raise ArgumentError, "background must be one of #{BACKGROUNDS.join(', ')}" if background && BACKGROUNDS.exclude?(background.to_s)

    @name = name
    @size = size
    @background = background&.to_s
  end

  attr_reader :size, :background

  def background?
    background.present?
  end

  def pictogram_href(layer)
    "#{asset_path("artwork/pictograms/#{@name}.svg")}#artwork-#{layer}"
  end

  def background_href(layer)
    "#{asset_path("artwork/background/#{background}.svg")}#artwork-#{layer}"
  end
end
