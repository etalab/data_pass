class AuthorizationRequestPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  def show?
    same_current_organization? ||
      current_user_is_contact?
  end

  def update?
    same_user_and_organization? &&
      record.in_draft?
  end

  def submit?
    same_user_and_organization? &&
      record.persisted? &&
      record.in_draft?
  end

  private

  def same_current_organization?
    record.organization == current_organization
  end

  def same_user_and_organization?
    record.applicant == user &&
      same_current_organization?
  end

  def current_user_is_contact?
    record.contact_types_for(user).any?
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
