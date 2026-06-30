class EntityEligibility::Rules::HubEECertDC
  def initialize(engine)
    @engine = engine
  end

  def verdict
    if engine.organization.legal_category == :commune
      EntityEligibility::Verdict.new(status: :eligible, reason: :commune)
    else
      EntityEligibility::Verdict.new(status: :ineligible, reason: :not_a_commune)
    end
  end

  private

  attr_reader :engine
end
