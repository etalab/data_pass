class AuthorizationPolicy < ApplicationPolicy
  def show?
    same_current_organization? ||
      record.request.contact_types_for(user).any? ||
      user.instructor?(record.kind)
  end

  def show_contact_support?
    (record.revoked? || record.state == 'revoked') && record.applicant == user
  end

  def reopen?
    user_is_applicant_and_active_authorization? ||
      user_has_at_least_one_contact_type_with_active_authorization?
  end

  def transfer?
    user_is_applicant_and_active_authorization? ||
      user_has_at_least_one_contact_type_with_active_authorization?
  end

  def start_next_stage?
    return false unless record.state == 'active' && !record.revoked?

    authorization_request_policy.start_next_stage?
  end

  def show_instruction?
    record.state == 'active' &&
      user.instructor?(record.kind)
  end

  private

  def authorization_request_policy
    @authorization_request_policy ||= AuthorizationRequestPolicy.new(user_context, record.authorization_request)
  end

  def user_is_applicant_and_active_authorization?
    record.state == 'active' &&
      !record.revoked? &&
      record.applicant == user
  end

  def user_has_at_least_one_contact_type_with_active_authorization?
    record.state == 'active' &&
      !record.revoked? &&
      record.request.contact_types_for(user).any?
  end

  def same_current_organization?
    current_organization.present? &&
      record.organization == current_organization
  end
end
