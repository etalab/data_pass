class RecordNotificationPolicyOnEvent < ApplicationInteractor
  def call
    return unless context.notification_policy.suppressed_any?

    context.authorization_request_event&.update!(notifications_disabled: true)
  end
end
