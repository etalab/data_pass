module FeatureFlag
  RULES = {
    depot_dossier_mariage: ->(**) { !Rails.env.production? },
    proconnect_dirigeant: ->(**) { !Rails.env.production? || Setting.fetch(:proconnect_dirigeant_open) },
    registre_wallet: ->(**) { !Rails.env.production? || Setting.fetch(:european_wallet_registry_open) },
    authorization_definitions: ->(user: nil, **) { user&.admin? || Rails.env.test? },
    european_wallet_registry_open: ->(**) { Setting.fetch(:european_wallet_registry_open) }
  }.freeze

  def self.enabled?(name, **context)
    rule = RULES[name.to_sym]

    rule.nil? || rule.call(**context)
  end
end
