class AuthorizationRequestPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  def show?
    same_user?
  end

  def update?
    same_user? &&
      record.in_draft?
  end

  def submit?
    same_user? &&
      record.persisted? &&
      record.in_draft?
  end

  private

  def same_user?
    record.applicant == user &&
      record.organization == current_organization
  end

  def unicity_constraint_violated?
    return false unless record.unique?

    another_authorization_request_with_same_type_exists?
  end

  def another_authorization_request_with_same_type_exists?
    current_organization.authorization_requests.where(type: record.to_s).any?
  end

  class Scope < Scope
    def resolve
      scope.where(organization: current_organization)
    end
  end
end
