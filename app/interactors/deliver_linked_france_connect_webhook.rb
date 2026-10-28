class DeliverLinkedFranceConnectWebhook < ApplicationInteractor
  def call
    return unless context.linked_france_connect_authorization

    deliver_fc_webhook
  end

  private

  def deliver_fc_webhook
    webhooks = Webhook.active_for_event(event_name, france_connect_definition_id)
    return if webhooks.empty?

    payload = webhook_payload

    webhooks.each do |webhook|
      DeliverAuthorizationRequestWebhookJob.perform_later(
        webhook.id,
        context.authorization_request.id,
        event_name.to_s,
        payload
      )
    end
  end

  def event_name
    context.state_machine_event
  end

  def france_connect_definition_id
    'france_connect'
  end

  def webhook_payload
    WebhookSerializer.new(
      france_connect_request,
      event_name,
      notifications: !context.notification_policy&.suppressed_any?,
      source: context.event_source
    ).serializable_hash
  end

  def france_connect_request
    context.linked_france_connect_authorization.request_as_validated(load_documents: false)
  end
end
