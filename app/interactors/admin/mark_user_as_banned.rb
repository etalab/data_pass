class Admin::MarkUserAsBanned < ApplicationInteractor
  def call
    validate!

    context.target_user.update!(
      banned_at: Time.zone.now,
      ban_reason: context.ban_reason,
    )
  rescue ActiveRecord::RecordInvalid
    context.fail!(error: :missing_reason)
  end

  private

  def validate!
    context.fail!(error: :cannot_ban_self) if context.target_user == context.admin
    context.fail!(error: :already_banned) if context.target_user.banned?
  end
end
