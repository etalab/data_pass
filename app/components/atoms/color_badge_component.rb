class Atoms::ColorBadgeComponent < ApplicationComponent
  ALLOWED_COLORS = %w[
    blue-ecume
    blue-cumulus
    purple-glycine
    pink-macaron
    pink-tuile
    yellow-tournesol
    yellow-moutarde
    orange-terre-battue
    brown-cafe-creme
    brown-caramel
    brown-opera
    beige-gris-galet
    green-tilleul-verveine
    green-bourgeon
    green-emeraude
    green-menthe
    green-archipel
  ].freeze

  ALLOWED_SIZES = %i[sm md].freeze

  ROLE_COLORS = {
    'manager' => 'purple-glycine',
    'instructor' => 'pink-tuile',
    'reporter' => 'yellow-tournesol',
    'developer' => 'blue-ecume',
  }.freeze

  def self.for_role(role_type, label:)
    new(label: label, color: ROLE_COLORS.fetch(role_type))
  end

  def initialize(label:, color:, size: :sm)
    raise ArgumentError, "color must be one of #{ALLOWED_COLORS}" unless ALLOWED_COLORS.include?(color)
    raise ArgumentError, "size must be one of #{ALLOWED_SIZES}" unless ALLOWED_SIZES.include?(size)

    @label = label
    @color = color
    @size = size
  end

  def call
    content_tag(:p, @label, class: classes)
  end

  private

  def classes
    ['fr-badge', "fr-badge--#{@size}", "fr-badge--#{@color}", 'fr-badge--no-icon']
  end
end
