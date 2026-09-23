module FeatureFlag
  RULES = {
    depot_dossier_mariage: ->(**) { !Rails.env.production? },
    authorization_definitions: ->(user: nil, **) { user&.admin? || Rails.env.test? }
  }.freeze

  def self.enabled?(name, **context)
    rule = RULES[name.to_sym]

    rule.nil? || rule.call(**context)
  end
end
