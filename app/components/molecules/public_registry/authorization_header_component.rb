class Molecules::PublicRegistry::AuthorizationHeaderComponent < ApplicationComponent
  def initialize(denomination:, origin:)
    @denomination = denomination
    @origin = Molecules::PublicRegistry::Origin.new(origin)
  end

  def call
    safe_join([badges, tag.h1(displayed_denomination, class: 'fr-h2')])
  end

  private

  attr_reader :denomination, :origin

  def badges
    tag.ul(class: 'fr-badges-group') do
      safe_join([tag.li(status_badge), tag.li(origin_badge)])
    end
  end

  def status_badge
    render DsfrComponent::BadgeComponent.new(status: :success, size: :sm).with_content(t('public_registry.status.active'))
  end

  def origin_badge
    render Atoms::ColorBadgeComponent.new(label: origin.label, color: origin.color)
  end

  def displayed_denomination
    denomination.presence || t('public_registry.not_provided')
  end
end
