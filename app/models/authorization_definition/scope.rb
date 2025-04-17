class AuthorizationDefinition::Scope
  attr_reader :name, :value, :group, :link, :deprecated_since

  def initialize(properties)
    @name = properties.fetch(:name)
    @value = properties.fetch(:value)
    @group = properties.fetch(:group, nil)
    @link = properties.fetch(:link, nil)
    @included = properties.fetch(:included, false)
    @disabled = properties.fetch(:disabled, false)
    @deprecated = properties.fetch(:deprecated, false)
    @deprecated_since = properties.fetch(:deprecated_since, nil)
    @deprecated_since = Date.parse(@deprecated_since) if @deprecated_since.is_a?(String)
  end

  def included?
    @included
  end

  def disabled?
    @disabled
  end

  def deprecated?
    @deprecated || @deprecated_since.present?
  end

  def deprecated_for?(entity)
    return true if @deprecated
    return false if @deprecated_since.nil?

    entity_date = entity.respond_to?(:created_at) && entity.created_at ? entity.created_at.to_date : nil
    entity_date.present? && entity_date >= @deprecated_since
  end

  def link?
    link.present?
  end
end
