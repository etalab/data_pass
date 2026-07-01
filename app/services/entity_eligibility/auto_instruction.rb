class EntityEligibility::AutoInstruction
  def initialize(authorization_request, verdict)
    @authorization_request = authorization_request
    @verdict = verdict
  end

  def happened?
    status.present?
  end

  def status
    return :validated if validated?

    :refused if refused?
  end

  private

  def validated?
    @authorization_request.validated? && @verdict.eligible?
  end

  def refused?
    @authorization_request.refused? && @verdict.ineligible?
  end
end
