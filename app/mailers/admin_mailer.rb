class AdminMailer < ApplicationMailer
  def notify_user_roles_change
    @user = params[:user]
    @removed_roles = (params[:old_roles] || []) - @user.roles
    @new_roles = @user.roles - (params[:old_roles] || [])

    mail(
      bcc: admin_users.pluck(:email),
      subject: "Nouveaux rôles ajouté à l'utilisateur #{@user.email}",
    )
  end

  private

  def admin_users
    User.admin
  end
end
