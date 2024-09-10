class AuthorizationRequestPolicy < ApplicationPolicy
  include CommonAuthorizationModelsPolicies

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
    record.persisted? &&
      submit?
  end

  def archive?
    record.persisted? &&
      same_user_and_organization? &&
      record.can_archive?
  end

  def reopen?
    record.persisted? &&
      same_user_and_organization? &&
      record.can_reopen?
  end

  def messages?
    record.persisted? &&
      record.applicant == user
  end

  def send_message?
    messages?
  end

  def transfer?
    record.persisted? &&
      same_current_organization? &&
      (record.reopening? || record.state != 'draft')
  end

  protected

  def authorization_request_class
    record.to_s
  end

  def authorization_definition
    record.definition
  end

  private

  def same_current_organization?
    current_organization.present? &&
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

  class Scope < Scope
    def resolve
      authorization_requests = scope.where(organization: current_organization)

      if registered_subdomain?
        authorization_requests.where(type: registered_subdomain.authorization_request_types)
      else
        authorization_requests
      end
    end
  end
end
