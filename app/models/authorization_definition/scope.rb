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
    @disabled
  end

  def deprecated_date
    return nil if @deprecated_since.blank?

    begin
      @deprecated_since.is_a?(String) ? Date.parse(@deprecated_since) : @deprecated_since
    rescue TypeError, ArgumentError
      nil
    end
  end

  def deprecated?
    deprecated_date.present? && deprecated_date < Time.zone.today
  end

  def deprecated_for?(entity)
    return false unless deprecated_date

    entity_date = entity.created_at.nil? ? Time.zone.today : entity.created_at.to_date
    entity_date >= deprecated_date
  end

  def link?
    link.present?
  end
end
