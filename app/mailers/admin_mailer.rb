class AdminMailer < ApplicationMailer
  def notify_user_roles_change
    @user = params[:user]
    @old_roles = params[:old_roles] || []
    @new_roles = @user.roles - @old_roles

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
