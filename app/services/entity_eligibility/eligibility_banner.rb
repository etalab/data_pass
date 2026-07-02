class EntityEligibility::EligibilityBanner
  AUTO_INSTRUCTION_STATUSES = {
    'auto_approve' => :validated,
    'auto_reject' => :refused,
  }.freeze
  REVIEW_STATUSES = %i[likely_eligible likely_ineligible].freeze

  def initialize(authorization_request, verdict)
    @authorization_request = authorization_request
    @verdict = verdict
  end

  def visible?
    status.present?
  end

  def status
    auto_instruction_status || review_status
  end

  private

  def auto_instruction_status
    AUTO_INSTRUCTION_STATUSES[latest_auto_instruction_event_name]
  end

  def latest_auto_instruction_event_name
    @authorization_request
      .events_without_bulk_update
      .where(name: AUTO_INSTRUCTION_STATUSES.keys)
      .order(:created_at)
      .last
      &.name
  end

  def review_status
    @verdict.status if REVIEW_STATUSES.include?(@verdict.status)
  end
end
