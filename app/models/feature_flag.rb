module FeatureFlag
  RULES = {
    depot_dossier_mariage: ->(**) { !Rails.env.production? },
    authorization_definitions: ->(user: nil, **) { user&.admin? || Rails.env.test? },
    hubee_formulaire_qf_notification: ->(**) { Rails.env.production? || Rails.env.local? }
  }.freeze

  def self.enabled?(name, **context)
    rule = RULES[name.to_sym]

    rule.nil? || rule.call(**context)
  end
end
