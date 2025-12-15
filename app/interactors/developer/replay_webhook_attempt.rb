class Developer::ReplayWebhookAttempt < ApplicationInteractor
  def call
    original_attempt = context.webhook_attempt
    result = make_http_request(original_attempt)
    save_new_webhook_attempt(original_attempt, result)
  rescue Faraday::Error => e
    context.fail!(error: :webhook_request_failed, message: e.message)
  end

  private

  def make_http_request(original_attempt)
    webhook = original_attempt.webhook
    http_service = WebhookHttpService.new(webhook.url, webhook.secret)
    http_service.call(original_attempt.payload)
  end

  def save_new_webhook_attempt(original_attempt, http_result)
    save_result = Developer::SaveWebhookAttempt.call(
      webhook: original_attempt.webhook,
      authorization_request: original_attempt.authorization_request,
      event_name: original_attempt.event_name,
      status_code: http_result[:status_code],
      response_body: http_result[:response_body],
      payload: original_attempt.payload
    )

    if save_result.success?
      context.webhook_attempt = save_result.webhook_attempt
    else
      context.fail!(error: save_result.error)
    end
  end
end
