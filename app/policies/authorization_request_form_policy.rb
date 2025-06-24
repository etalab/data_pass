class AuthorizationRequestFormPolicy < ApplicationPolicy
  include CommonAuthorizationModelsPolicies

  def new?
    record.startable_by_applicant &&
      super
  end

  protected

  def authorization_request_class
    record.authorization_request_class.to_s
  end

  def authorization_definition
    record.authorization_definition
  end
end
