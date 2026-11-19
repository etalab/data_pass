class Molecules::PublicRegistry::OriginFilterComponent < ApplicationComponent
  PLACEMENTS = %i[sidebar mobile].freeze

  def initialize(url:, placement:, origins: [], query: nil)
    raise ArgumentError, "placement must be one of #{PLACEMENTS}" unless PLACEMENTS.include?(placement)

    @url = url
    @placement = placement
    @origins = Molecules::PublicRegistry::Origin.normalize(origins)
    @query = query
  end

  attr_reader :url, :placement, :origins, :query

  def title_id
    "public-registry-origin-#{placement}"
  end

  def sidebar?
    placement == :sidebar
  end

  def tag_for(value)
    DsfrComponent::TagComponent.new(
      title: Molecules::PublicRegistry::Origin.new(value).label,
      size: :sm,
      selected: origins.include?(value),
      html_attributes: { type: 'submit', name: 'origine', value: value_after_click(value) }
    )
  end

  private

  def value_after_click(value)
    toggled = origins.include?(value) ? origins - [value] : origins + [value]
    Molecules::PublicRegistry::Origin.normalize(toggled).join(',')
  end
end
