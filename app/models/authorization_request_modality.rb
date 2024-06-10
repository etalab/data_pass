class AuthorizationRequestModality
  attr_reader :name,
              :value,
              :included

  def initialize(properties)
    @name = properties.fetch(:name)
    @value = properties.fetch(:value)
    @included = properties.fetch(:included, false)
  end

  def included? = included

  def link? = false
end
