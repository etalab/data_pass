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
    feature_enabled?(:reopening) &&
      !record.dirty_from_v1? &&
      record.persisted? &&
      same_user_and_organization? &&
      record.can_reopen?
  end

  def cancel_reopening?
    feature_enabled?(:reopening) &&
      !record.dirty_from_v1? &&
      same_user_and_organization? &&
      record.can_cancel_reopening? &&
      !record.submitted?
  end

  def submit_reopening?
    feature_enabled?(:reopening) &&
      same_user_and_organization? &&
      changed_since_latest_approval?
  end

  def messages?
    feature_enabled?(:messaging) &&
      record.persisted? &&
      record.applicant == user
  end

  def send_message?
    messages?
  end

  def transfer?
    feature_enabled?(:transfer) &&
      !record.dirty_from_v1? &&
      common_transfer?
  end

  def manual_transfer_from_instructor?
    !feature_enabled?(:transfer) &&
      common_transfer?
  end

  def start_next_stage?
    same_user_and_organization? &&
      record.definition.next_stage? &&
      record.validated?
  end

  def cancel_next_stage?
    same_user_and_organization? &&
      record.definition.previous_stage? &&
      record.filling? &&
      record.can_cancel_next_stage? &&
      record.authorizations.any?
  end

  def ongoing_request?
    same_user_and_organization? &&
      record.draft?
  end

  protected

  def common_transfer?
    record.persisted? &&
      same_current_organization? &&
      (record.reopening? || record.state != 'draft')
  end

  def authorization_request_class
    record.to_s
  end

  def authorization_definition
    record.definition
  end

  def feature_enabled?(name)
    authorization_definition.feature?(name)
  end

  private

  def changed_since_latest_approval?
    previous_data = Hash(record.latest_authorization_of_class(original_record.class_name)&.data)
    current_data = Hash(record.data)
    previous_data != current_data.slice(*previous_data.keys)
  end

  def original_record
    return record.object if record.decorated?

    record
  end

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
