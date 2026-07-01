class EntityEligibility::EligibilityBanner
  REVIEW_STATUSES = %i[likely_eligible likely_ineligible].freeze

  def initialize(authorization_request, verdict)
    @authorization_request = authorization_request
    @verdict = verdict
  end

  def visible?
    status.present?
  end

  def status
    return :validated if auto_validated?
    return :refused if auto_refused?

    review_status
  end

  private

  def auto_validated?
    @authorization_request.validated? && @verdict.eligible?
  end

  def auto_refused?
    @authorization_request.refused? && @verdict.ineligible?
  end

  def review_status
    @verdict.status if REVIEW_STATUSES.include?(@verdict.status)
  end
end
