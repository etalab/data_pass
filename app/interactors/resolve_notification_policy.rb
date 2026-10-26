class ResolveNotificationPolicy < ApplicationInteractor
  def call
    context.notification_policy = NotificationPolicy.for_api_call(
      data_provider: context.authorization_request.definition.provider,
      action: context.notification_action,
      notifications: context.notifications
    )
  end
end
