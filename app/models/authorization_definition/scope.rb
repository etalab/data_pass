class AuthorizationDefinition::Scope
  attr_reader :name, :value, :group, :link

  def initialize(properties)
    @name = properties.fetch(:name)
    @value = properties.fetch(:value)
    @group = properties.fetch(:group, nil)
    @link = properties.fetch(:link, nil)
    @included = properties.fetch(:included, false)
    @disabled = properties.fetch(:disabled, false)
    @deprecated_since = properties.fetch(:deprecated_since, nil)
  end

  def included?
    @included
  end

  def disabled?
    @disabled || deprecated?
  end

  def deprecated_date
    Date.parse(@deprecated_since)
  rescue TypeError, Date::Error
    nil
  end

  def available?(request)
    return false if entity_created_after_deprecation_date?(request)
    return true if request.form.scopes_config[:displayed].blank?

    request.form.scopes_config[:displayed].include?(value)
  end

  def deprecated?
    deprecated_date.present? && deprecated_date < Time.zone.today
  end

  def entity_created_after_deprecation_date?(entity)
    return false unless deprecated_date

    entity_date = entity.created_at.nil? ? Time.zone.today : entity.created_at.to_date
    entity_date >= deprecated_date
  end

  def link?
    link.present?
  end

  def disabled_by_config?(request)
    disabled_config = request.form.scopes_config[:disabled]
    return false if disabled_config.blank?

    disabled_config.include?(value)
  end
end
