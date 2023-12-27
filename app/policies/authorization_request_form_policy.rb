class AuthorizationRequestFormPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  private

  def unicity_constraint_violated?
    return false unless record.unique

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization.authorization_requests.where(type: record.authorization_request_class.to_s).any?
  end
end
