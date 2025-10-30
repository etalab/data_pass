class Developer::ReplayWebhookCall < ApplicationInteractor
  def call
    original_call = find_webhook_call
    result = make_http_request(original_call)
    save_new_webhook_call(original_call, result)
  rescue ActiveRecord::RecordNotFound
    context.fail!(error: :webhook_call_not_found)
  rescue Faraday::Error => e
    context.fail!(error: :webhook_request_failed, message: e.message)
  end

  private

  def find_webhook_call
    WebhookCall.find(context.webhook_call_id)
  end

  def make_http_request(original_call)
    webhook = original_call.webhook
    http_service = WebhookHttpService.new(webhook.url, webhook.secret)
    http_service.call(original_call.payload)
  end

  def save_new_webhook_call(original_call, http_result)
    save_result = Developer::SaveWebhookCall.call(
      webhook: original_call.webhook,
      authorization_request: original_call.authorization_request,
      event_name: original_call.event_name,
      status_code: http_result[:status_code],
      response_body: http_result[:response_body],
      payload: original_call.payload
    )

    if save_result.success?
      context.webhook_call = save_result.webhook_call
    else
      context.fail!(error: save_result.error)
    end
  end
end
