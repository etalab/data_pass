class AuthorizationRequestPolicy < ApplicationPolicy
  include CommonAuthorizationModelsPolicies

  def show?
    same_user_and_organization? &&
      record.draft?
  end

  def summary?
    if same_user_and_organization?
      !record.draft? ||
        record.reopening? ||
        review_authorization_request.success?
    elsif same_current_organization? && user.current_organization_verified?
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
    record.authorizations.any? do |authorization|
      AuthorizationPolicy.new(user_context, authorization).reopen?
    end
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
      (record.reopening? || record.state != 'draft' || production_draft?)
  end

  def production_draft?
    record.multi_stage? &&
      record.definition.stage.type == 'production' &&
      record.draft?
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

  def review_authorization_request
    ReviewAuthorizationRequest.call(
      authorization_request: record,
      user:,
    )
  end

  def current_user_is_contact?
    record.contact_types_for(user).any?
  end

  class Scope < Scope
    def resolve
      authorization_requests = scope

      authorization_requests = if user.current_organization_verified?
                                 authorization_requests.where(organization: user.current_organization)
                               else
                                 authorization_requests.where(applicant: user)
                               end

      if registered_subdomain?
        authorization_requests.where(type: registered_subdomain.authorization_request_types)
      else
        authorization_requests
      end
    end
  end
end
