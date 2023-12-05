class AuthorizationRequestTemplate
  attr_reader :id, :name, :attributes

  def initialize(id, properties)
    @id = id.to_s
    @name = properties[:name]
    @attributes = properties[:attributes]
  end
end
