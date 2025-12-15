class DeliverAuthorizationRequestWebhookJob < ApplicationJob
  include KeepTrackOfJobAttempts

  THRESHOLD_TO_NOTIFY_DATA_PROVIDER = 5

  class WebhookDeliveryFailedError < StandardError; end

  retry_on(WebhookDeliveryFailedError, wait: :polynomially_longer, attempts: :unlimited)

  def perform(webhook_id, authorization_request_id, event_name, payload) # rubocop:disable Metrics/AbcSize
    webhook = Webhook.find(webhook_id)
    authorization_request = AuthorizationRequest.find(authorization_request_id)

    http_service = WebhookHttpService.new(webhook.url, webhook.secret)

    payload = JSON.parse(payload) if payload.is_a?(String)

    result = http_service.call(payload)

    Developer::SaveWebhookAttempt.call!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: event_name,
      status_code: result[:status_code],
      response_body: result[:response_body],
      payload: payload
    )

    if success_http_codes.include?(result[:status_code])
      handle_success(result[:response_body], authorization_request)
    else
      handle_error(result, webhook, payload, authorization_request)
    end
  end

  private

  def handle_success(response_body, authorization_request)
    json = JSON.parse(response_body)

    return unless json && json['token_id'].present?

    authorization_request.update(
      external_provider_id: json['token_id']
    )
  rescue JSON::ParserError
    nil
  end

  def handle_error(result, webhook, payload, authorization_request)
    track_error(result, webhook, payload, authorization_request)
    notify_webhook_fail(webhook, payload, result) if attempts == THRESHOLD_TO_NOTIFY_DATA_PROVIDER
    webhook_fail!
  end

  def webhook_fail!
    raise WebhookDeliveryFailedError
  end

  def track_error(result, webhook, payload, authorization_request)
    Sentry.set_extras(
      {
        webhook_id: webhook.id,
        authorization_definition_id: webhook.authorization_definition_id,
        authorization_request_id: authorization_request.id,
        payload: payload,
        tries_count: attempts,
        webhook_response_status: result[:status_code],
        webhook_response_body: result[:response_body]
      }
    )

    Sentry.capture_message("Fail to call target's api webhook endpoint")
  end

  def notify_webhook_fail(webhook, _payload, _result)
    WebhookMailer.with(
      webhook: webhook
    ).fail.deliver_later
  end

  def success_http_codes
    WebhookAttempt::SUCCESS_STATUS_CODES
  end
end
