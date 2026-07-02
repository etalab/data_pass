module FeatureFlag
  RULES = {
    authorization_definitions: ->(user: nil, **) { user&.admin? || Rails.env.test? }
  }.freeze

  def self.enabled?(name, **context)
    rule = RULES[name.to_sym]

    rule.nil? || rule.call(**context)
  end
end
