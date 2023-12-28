class AuthorizationRequestPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  def show?
    record.applicant == user
  end

  def update?
    record.applicant == user &&
      record.in_draft? &&
      record.applicant == user
  end

  def submit?
    record.persisted? &&
      record.in_draft? &&
      record.applicant == user
  end

  private

  def unicity_constraint_violated?
    return false unless record.unique?

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization.authorization_requests.where(type: record.to_s).any?
  end
end
