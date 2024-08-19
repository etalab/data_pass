class NewAuthorizationRequest
  def self.facade(scope:)
    new(scope:).facade
  end

  def initialize(scope:)
    @scope = scope
  end

  def facade
    return APIEntrepriseFacade if api_entreprise?

    DefaultFacade
  end

  private

  attr_reader :scope

  def api_entreprise?
    /api.entreprise/.match?(scope)
  end
end
