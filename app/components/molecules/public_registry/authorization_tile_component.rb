class Molecules::PublicRegistry::AuthorizationTileComponent < ApplicationComponent
  SEPARATOR = ' · '.freeze

  def initialize(url:, entry:, origin:)
    @url = url
    @entry = entry
    @origin = Molecules::PublicRegistry::Origin.new(origin)
  end

  def call
    render(tile) do |component|
      component.with_badge(status: :success, size: :sm) { t('public_registry.status.active') }
      component.with_badge(size: :sm, html_attributes: { class: origin.badge_classes }) { origin.label }
    end
  end

  private

  attr_reader :url, :entry, :origin

  def tile
    DsfrComponent::TileComponent.new(
      title:,
      url:,
      description:,
      orientation: :horizontal,
      heading_level: 2,
      html_attributes: { class: 'r-code' },
    )
  end

  def title
    safe_join([displayed_denomination, screen_reader_only("#{SEPARATOR}#{entry.service}")])
  end

  def description
    safe_join(
      [
        screen_reader_only(t('.service_label')), entry.service, SEPARATOR,
        screen_reader_only(t('.provider_label')), entry.provider, SEPARATOR,
        t('.validated_on', date: l(entry.validated_on)), SEPARATOR,
        entry.number
      ]
    )
  end

  def displayed_denomination
    entry.denomination.presence || t('public_registry.not_provided')
  end

  def screen_reader_only(text)
    tag.span(text, class: 'fr-sr-only')
  end
end
