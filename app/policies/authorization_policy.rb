class AuthorizationPolicy < ApplicationPolicy
  include CommonAuthorizationModelsPolicies

  def contact_support?
    record.revoked? &&
      record.applicant == user
  end

  def reopen?
    feature_enabled?(:reopening) &&
      same_request_user_and_organization? &&
      record.reopenable?
  end

  def show?
    same_current_verified_organization? ||
      record.request.contact_types_for(user).any? ||
      user.reporter?(record.kind)
  end

  def start_next_stage?
    record.active? &&
      authorization_request_policy.start_next_stage?
  end

  def transfer?
    record.active? &&
      authorization_request_policy.transfer?
  end

  def manual_transfer_from_instructor?
    record.active? &&
      authorization_request_policy.manual_transfer_from_instructor?
  end

  private

  def authorization_definition
    record.definition
  end

  def authorization_request_policy
    @authorization_request_policy ||= AuthorizationRequestPolicy.new(user_context, record.authorization_request)
  end

  def same_current_verified_organization?
    same_current_organization? &&
      user.current_organization_verified?
  end

  def same_request_user_and_organization?
    record.request.applicant_id == user.id &&
      same_current_organization?
  end

  class Scope < Scope
    def resolve
      authorizations = scope.joins(request: :organization)

      authorizations = authorizations.where(authorization_request_class: registered_subdomain.authorization_request_types) if registered_subdomain?

      if user.current_organization_verified?
        authorizations.where(authorization_requests: { organization: current_organization })
      else
        authorizations.where(authorization_requests: { applicant: user })
      end
    end
  end
end
