class AuthorizationRequestFormPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated?
  end

  def unicity_constraint_violated?
    return false unless record.unique

    another_authorization_request_with_same_type_exists?
  end

  private

  def another_authorization_request_with_same_type_exists?
    current_organization.authorization_requests.where(type: record.authorization_request_class.to_s).any?
  end
end
