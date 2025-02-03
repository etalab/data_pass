class AdminMailerPreview < ActionMailer::Preview
  def notify_user_roles_change
    AdminMailer.with(user:, old_roles: %w[old_api:instructor]).notify_user_roles_change
  end

  private

  def user
    User.with_roles.first
  end
end
