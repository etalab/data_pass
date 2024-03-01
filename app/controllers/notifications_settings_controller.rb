class NotificationsSettingsController < AuthenticatedUserController
  def update
    current_user.update(settings_params)

    redirect_to profile_path
  end

  private

  def settings_params
    params.require(:user).permit(
      *notifications_permitted_settings
    )
  end

  def notifications_permitted_settings
    User.stored_attributes[:settings].select { |setting| setting.to_s.include?('_notification_') }
  end
end
