class AuthorizationPolicy < ApplicationPolicy
  def reopen?
    AuthorizationRequestPolicy.new(user, record.authorization_request).reopen?
  end
end
