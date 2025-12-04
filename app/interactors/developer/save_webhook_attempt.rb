class Developer::SaveWebhookAttempt < ApplicationInteractor
  def call
    context.webhook_attempt = build_webhook_attempt

    return if context.webhook_attempt.save

    context.fail!(error: :invalid_webhook_attempt_model)
  end

  private

  def build_webhook_attempt
    WebhookAttempt.new(
      webhook: context.webhook,
      authorization_request: context.authorization_request,
      event_name: context.event_name,
      status_code: context.status_code,
      response_body: context.response_body,
      payload: context.payload
    )
  end
end
