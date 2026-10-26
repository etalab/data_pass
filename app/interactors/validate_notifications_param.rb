class ValidateNotificationsParam < ApplicationInteractor
  def call
    return if NotificationPolicy.valid_value?(context.notifications)

    fail_with_error(:invalid_notifications)
  end
end
