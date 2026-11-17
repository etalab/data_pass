class Molecules::PublicRegistry::Origin
  COLORS = {
    'datapass' => 'blue-ecume',
    'portefeuille-europeen' => 'purple-glycine',
  }.freeze

  VALUES = COLORS.keys.freeze

  attr_reader :value

  def initialize(value)
    raise ArgumentError, "origin must be one of #{VALUES}" unless VALUES.include?(value)

    @value = value
  end

  def color
    COLORS.fetch(value)
  end

  def label
    I18n.t("public_registry.origins.#{value}")
  end

  def badge_classes
    "fr-badge--#{color} fr-badge--no-icon"
  end
end
