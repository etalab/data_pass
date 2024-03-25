class DeliverAuthorizationRequestWebhook < ApplicationInteractor
  def call
    return unless can_deliver_webhook?

    DeliverAuthorizationRequestWebhookJob.new(*job_params).enqueue
  end

  private

  def job_params
    [
      target_api,
      webhook_payload,
      context.authorization_request.id
    ]
  end

  def webhook_payload
    WebhookSerializer.new(
      context.authorization_request,
      context.state_machine_event || context.event_name
    ).serializable_hash
  end

  def target_api = context.authorization_request.definition.id

  def can_deliver_webhook?
    context.authorization_request.definition.webhook?
  end
end
