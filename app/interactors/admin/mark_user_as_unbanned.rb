class Admin::MarkUserAsUnbanned < ApplicationInteractor
  def call
    context.target_user.update!(
      banned_at: nil,
      ban_reason: nil,
    )
  end
end
