class Admin::BansController < AdminController
  def index
    @banned_users = User.banned.order(banned_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    organizer = Admin::BanUser.call(
      user_email: ban_params[:email],
      ban_reason: ban_params[:ban_reason],
      admin: current_user,
    )

    if organizer.success?
      handle_successful_ban(organizer)
    else
      @user = User.new(ban_params)
      handle_failed_ban(organizer)
    end
  end

  def confirm_destroy
    @user = User.banned.find(params[:id])
  end

  def destroy
    target_user = User.banned.find(params[:id])

    Admin::UnbanUser.call(
      target_user:,
      admin: current_user,
    )

    success_message(
      title: I18n.t('admin.bans.destroy.title'),
      description: I18n.t('admin.bans.destroy.description', email: target_user.email)
    )

    redirect_to admin_bans_path
  end

  private

  def ban_params
    params.fetch(:user, {}).permit(:email, :ban_reason)
  end

  def handle_successful_ban(organizer)
    success_message(
      title: I18n.t('admin.bans.create.title'),
      description: I18n.t('admin.bans.create.description', email: organizer.target_user.email)
    )
    redirect_to admin_bans_path
  end

  def handle_failed_ban(organizer)
    error_message(
      title: I18n.t('admin.bans.errors.title'),
      description: I18n.t("admin.bans.errors.#{organizer.error}")
    )
    render :new, status: :unprocessable_content
  end
end
