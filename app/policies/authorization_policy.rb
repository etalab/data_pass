class AuthorizationPolicy < ApplicationPolicy
  def show?
    record.organization == user.current_organization ||
      user.instructor?(authorization.kind)
  end

  def reopen?
    AuthorizationRequestPolicy.new(user, record.authorization_request).reopen?
  end
end
