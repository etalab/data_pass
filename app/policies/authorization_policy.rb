class AuthorizationPolicy < ApplicationPolicy
  def contact_support?
    record.revoked? &&
      record.applicant == user
  end

  def reopen?
    record.active? &&
      authorization_request_policy.reopen?
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

  def authorization_request_policy
    @authorization_request_policy ||= AuthorizationRequestPolicy.new(user_context, record.authorization_request)
  end

  def same_current_verified_organization?
    current_organization.present? &&
      user.current_organization_verified? &&
      record.organization == current_organization
  end

  class Scope < Scope
    def resolve
      authorizations = if user.current_organization_verified?
                         scope.joins(request: :organization).where(authorization_requests: { organization: current_organization })
                       else
                         scope.joins(request: :organization).where(authorization_requests: { applicant: user })
                       end

      if registered_subdomain?
        authorizations.where(authorization_request_class: registered_subdomain.authorization_request_types)
      else
        authorizations
      end
    end
  end
end
