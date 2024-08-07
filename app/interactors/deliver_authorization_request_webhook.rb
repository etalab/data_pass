class DeliverAuthorizationRequestWebhook < ApplicationInteractor
  def call
    return unless can_deliver_webhook?

    DeliverAuthorizationRequestWebhookJob.new(*job_params).enqueue
  end

  private

  def job_params
    [
      authorization_request_kind,
      webhook_payload,
      context.authorization_request.id
    ]
  end

  def webhook_payload
    WebhookSerializer.new(
      context.authorization_request,
      context.state_machine_event || context.event_name
    ).to_json
  end

  def authorization_request_kind = context.authorization_request.definition.id

  def can_deliver_webhook?
    context.authorization_request.definition.webhook?
  end
end
