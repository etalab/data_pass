class AuthorizationPolicy < ApplicationPolicy
  def show?
    same_current_organization? ||
      record.request.contact_types_for(user).any? ||
      user.instructor?(record.kind)
  end

  delegate :reopen?, to: :authorization_request_policy

  private

  def authorization_request_policy
    @authorization_request_policy ||= AuthorizationRequestPolicy.new(user_context, record.authorization_request)
  end

  def same_current_organization?
    current_organization.present? &&
      record.organization == current_organization
  end
end
