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
    rescue TypeError
      nil
    end
  end

  def deprecated?
    deprecated_date.present? && deprecated_date < Time.zone.today
  end

  def deprecated_for?(entity)
    return false if @deprecated_since.nil?

    (entity.created_at || Time.zone.today) >= @deprecated_since
  end

  def link?
    link.present?
  end
end
