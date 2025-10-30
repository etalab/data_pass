class Developer::SaveWebhookCall < ApplicationInteractor
  def call
    context.webhook_call = build_webhook_call

    return if context.webhook_call.save

    context.fail!(error: :invalid_webhook_call_model)
  end

  private

  def build_webhook_call
    WebhookCall.new(
      webhook: context.webhook,
      authorization_request: context.authorization_request,
      event_name: context.event_name,
      status_code: context.status_code,
      response_body: context.response_body,
      payload: context.payload
    )
  end
end
