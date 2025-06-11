class Admin::CreateImpersonation < ApplicationInteractor
  def call
    validate_target_user
    create_impersonation_record
    start_impersonation_session
    track_admin_event
  end

  private

  def validate_target_user
    context.fail!(error: :cannot_impersonate_self) if context.target_user == context.admin
    context.fail!(error: :cannot_impersonate_admin) if context.target_user.admin?
  end

  def create_impersonation_record
    context.impersonation = Impersonation.create!(
      user: context.target_user,
      admin: context.admin,
      reason: context.reason
    )
  end

  def start_impersonation_session
    context.session[:impersonated_user_id] = context.target_user.id
    context.session[:impersonation_id] = context.impersonation.id
  end

  def track_admin_event
    AdminEvent.create!(
      admin: context.admin,
      name: 'impersonate_user',
      entity: context.impersonation
    )
  end
end
