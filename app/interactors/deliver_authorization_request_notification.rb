class DeliverAuthorizationRequestNotification < ApplicationInteractor
  def call
    notifier_klass.new(context.authorization_request, notification_policy).public_send(
      event_name,
      params,
    )

    deliver_webhooks
  end

  private

  def event_name
    context.state_machine_event ||
      context.event_name
  end

  def params
    context.authorization_request_notifier_params || {}
  end

  def notification_policy
    context.notification_policy || NotificationPolicy.allow_all
  end

  def notifier_klass
    "#{context.authorization_request.class_name.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  def deliver_webhooks
    webhooks = Webhook.active_for_event(webhook_event_name, context.authorization_request.definition.id)
    return if webhooks.empty?

    payload = webhook_payload

    webhooks.each do |webhook|
      DeliverAuthorizationRequestWebhookJob.perform_later(
        webhook.id,
        context.authorization_request.id,
        webhook_event_name,
        payload
      )
    end
  end

  def webhook_event_name
    event_name.to_s.delete_suffix('_by_api')
  end

  def webhook_payload
    WebhookSerializer.new(
      context.authorization_request,
      webhook_event_name,
      notifications: !notification_policy.suppressed_any?,
      source: context.event_source
    ).serializable_hash
  end
end
