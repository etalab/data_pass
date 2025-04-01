class DeprecatePreviousAuthorizations < ApplicationInteractor
  delegate :authorization_request, :authorization, to: :context

  def call
    context.deprecated_authorizations = previous_authorizations.each(&:deprecate!)
  end

  private

  def previous_authorizations
    @previous_authorizations ||= same_stage_authorizations - [authorization]
  end

  def same_stage_authorizations
    @same_stage_authorizations ||= authorization_request.authorizations.where(authorization_request_class: authorization.authorization_request_class)
  end
end
