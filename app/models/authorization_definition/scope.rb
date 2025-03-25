class AuthorizationDefinition::Scope
  attr_reader :name,
    :value,
    :group,
    :link,
    :included

  def initialize(properties)
    @name = properties.fetch(:name)
    @value = properties.fetch(:value)
    @group = properties.fetch(:group, nil)
    @link = properties.fetch(:link, nil)
    @included = properties.fetch(:included, false)
  end

  def included?
    included
  end

  def link?
    link.present?
  end
end
