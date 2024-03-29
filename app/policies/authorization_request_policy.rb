class AuthorizationRequestPolicy < ApplicationPolicy
  def new?
    !unicity_constraint_violated? &&
      record.startable_by_applicant
  end

  def show?
    same_user_and_organization? &&
      record.draft?
  end

  def summary?
    if same_user_and_organization?
      !record.draft? ||
        review_authorization_request.success?
    elsif same_current_organization?
      true
    else
      record.contact_types_for(user).any?
    end
  end

  def update?
    same_user_and_organization? &&
      record.filling?
  end

  def submit?
    same_user_and_organization? &&
      record.persisted? &&
      record.can_submit?
  end

  def review?
    submit?
  end

  def archive?
    same_user_and_organization? &&
      record.can_archive?
  end

  def reopen?
    same_user_and_organization? &&
      record.can_reopen?
  end

  def messages?
    record.applicant == user &&
      !record.validated?
  end

  def send_message?
    messages?
  end

  private

  def same_current_organization?
    record.organization_id == current_organization.id
  end

  def review_authorization_request
    ReviewAuthorizationRequest.call(
      authorization_request: record,
      user:,
    )
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
    current_organization.active_authorization_requests.where(type: record.to_s).any?
  end

  class Scope < Scope
    def resolve
      scope.where(organization: current_organization)
    end
  end
end
