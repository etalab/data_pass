class Admin::CaptureUserBanAttributes < ApplicationInteractor
  def call
    context.admin_before_attributes = {
      banned_at: context.target_user.banned_at,
      ban_reason: context.target_user.ban_reason,
    }
  end
end
