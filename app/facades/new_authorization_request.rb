class NewAuthorizationRequest
  def self.facade(definition_id:)
    new(definition_id:).facade
  end

  def initialize(definition_id:)
    @definition_id = definition_id
  end

  def facade
    Kernel.const_get("NewAuthorizationRequest::#{@definition_id.camelize}Facade")
  rescue NameError
    DefaultFacade
  end
end
