class AuthorizationPolicy < ApplicationPolicy
  def show?
    authorization_request_policy.summary? ||
      user.instructor?(record.kind)
  end

  delegate :reopen?, to: :authorization_request_policy

  private

  def authorization_request_policy
    @authorization_request_policy ||= AuthorizationRequestPolicy.new(user_context, record.authorization_request)
  end
end
