class EntityEligibility::Rules::Base
  def initialize(engine)
    @engine = engine
  end

  private

  attr_reader :engine

  def organization
    engine.organization
  end

  def authorization_request
    engine.authorization_request
  end

  EntityEligibility::Verdict::STATUSES.each do |status|
    define_method(status) do |reason = nil|
      EntityEligibility::Verdict.new(status:, reason:)
    end
  end
end
