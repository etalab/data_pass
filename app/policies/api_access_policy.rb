class APIAccessPolicy < ApplicationPolicy
  delegate :oauth_application, to: :user_context

  def submit?
    granted?('submission')
  end

  def validate?
    granted?('validation')
  end

  private

  def granted?(action)
    user.present? && user_has_developer_role_for_request_type? && APIAccessGrant.active_for?(
      application: oauth_application,
      data_provider_id: record.provider&.id,
      action:
    )
  end

  def user_has_developer_role_for_request_type?
    user.authorization_request_types_for(:developer).include?(record.authorization_request_class.to_s)
  end
end
