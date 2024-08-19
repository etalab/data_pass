class AuthorizationRequestFormPolicy < ApplicationPolicy
  include CommonAuthorizationModelsPolicies

  protected

  def authorization_request_class
    record.authorization_request_class.to_s
  end

  def authorization_definition
    record.authorization_definition
  end
end
