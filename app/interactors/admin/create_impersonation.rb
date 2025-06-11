class Admin::CreateImpersonation < ApplicationInteractor
  def call
    validate_target_user
    create_impersonation_record
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
end
