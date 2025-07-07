class NotificationsSettingsController < AuthenticatedUserController
  def update
    current_user.update(settings_params)

    redirect_to profile_path
  end

  private

  def settings_params
    params.expect(
      user: [*notifications_permitted_settings]
    )
  end

  def notifications_permitted_settings
    User.stored_attributes[:settings].select { |setting| setting.to_s.include?('_notifications_') }
  end

  def model_to_track_for_impersonation
    current_user
  end
end
