class DeliverAuthorizationRequestNotification < ApplicationInteractor
  def call
    notifier_klass.new(context.authorization_request).public_send(
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

  def notifier_klass
    "#{context.authorization_request.class_name.demodulize}Notifier".constantize
  rescue NameError
    BaseNotifier
  end

  def deliver_webhooks
    webhooks = Webhook.active_for_event(event_name, context.authorization_request.definition.id)

    webhooks.each do |webhook|
      DeliverAuthorizationRequestWebhookJob.perform_later(
        webhook.id,
        context.authorization_request.id,
        event_name.to_s,
        webhook_payload
      )
    end
  end

  def webhook_payload
    WebhookSerializer.new(
      context.authorization_request,
      event_name
    ).to_json
  end
end
