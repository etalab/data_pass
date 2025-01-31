class Admin::NotifyAdminsForRolesUpdate < ApplicationInteractor
  def call
    AdminMailer.with(user: context.user, old_roles: context.admin_before_attributes[:roles]).notify_user_roles_change.deliver_later
  end
end
