class AuthorizationRequestScope
  attr_reader :name, :value, :group

  def initialize(properties)
    @name = properties.fetch(:name)
    @value = properties.fetch(:value)
    @group = properties.fetch(:group, nil)
  end
end
