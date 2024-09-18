class NewAuthorizationRequest
  def self.facade(definition_id:)
    new(definition_id:).facade
  end

  def initialize(definition_id:)
    @definition_id = definition_id
  end

  def facade
    return APIEntrepriseFacade if api_entreprise?

    DefaultFacade
  end

  private

  attr_reader :definition_id

  def api_entreprise?
    definition_id == 'api_entreprise'
  end
end
