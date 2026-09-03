class DeliverAuthorizationRequestWebhookJob < ApplicationJob
  MAX_DELIVERY_ATTEMPTS = 10
  EXECUTIONS_BEFORE_NOTIFYING_DATA_PROVIDER = 5
  FAILURE_ALERT_THROTTLE_WINDOW = 2.hours

  class WebhookDeliveryFailedError < StandardError; end

  retry_on(WebhookDeliveryFailedError, wait: :polynomially_longer, attempts: MAX_DELIVERY_ATTEMPTS) do |job, _error|
    job.abandon_delivery!
  end

  def perform(webhook_id, authorization_request_id, event_name, payload) # rubocop:disable Metrics/AbcSize
    webhook = Webhook.find(webhook_id)
    authorization_request = AuthorizationRequest.find(authorization_request_id)

    http_service = WebhookHttpService.new(webhook.url, webhook.secret)

    payload = JSON.parse(payload) if payload.is_a?(String)

    result = call_endpoint(http_service, payload)

    @webhook_attempt = Developer::SaveWebhookAttempt.call!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: event_name,
      status_code: result[:status_code],
      response_body: result[:response_body],
      payload: payload
    ).webhook_attempt

    if success_http_codes.include?(result[:status_code])
      webhook.reset_failure_alert!
      handle_success(result[:response_body], authorization_request)
    else
      handle_error(result, webhook, payload, authorization_request)
    end
  end

  def abandon_delivery!
    Developer::MarkWebhookAttemptAsAbandoned.call(webhook_attempt: @webhook_attempt)
    track_abandon
  rescue StandardError => e
    Sentry.capture_exception(e, extras: { webhook_attempt_id: @webhook_attempt&.id })
  end

  private

  def call_endpoint(http_service, payload)
    http_service.call(payload)
  rescue Faraday::Error => e
    { status_code: nil, response_body: "#{e.class.name}: #{e.message}" }
  end

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
    notify_webhook_fail(webhook) if executions == EXECUTIONS_BEFORE_NOTIFYING_DATA_PROVIDER
    webhook_fail!
  end

  def webhook_fail!
    raise WebhookDeliveryFailedError
  end

  def track_error(result, webhook, payload, authorization_request)
    Sentry.set_extras(sentry_extras(result, webhook, payload, authorization_request))

    Sentry.capture_message("Fail to call target's api webhook endpoint")
  end

  def track_abandon
    result = { status_code: @webhook_attempt.status_code, response_body: @webhook_attempt.response_body }

    Sentry.set_extras(sentry_extras(result, @webhook_attempt.webhook, @webhook_attempt.payload, @webhook_attempt.authorization_request))

    Sentry.capture_message('Webhook delivery abandoned after max attempts', level: :error)
  end

  def sentry_extras(result, webhook, payload, authorization_request)
    {
      webhook_id: webhook.id,
      authorization_definition_id: webhook.authorization_definition_id,
      authorization_request_id: authorization_request.id,
      payload: payload,
      tries_count: executions,
      webhook_response_status: result[:status_code],
      webhook_response_body: result[:response_body]
    }
  end

  def notify_webhook_fail(webhook)
    Developer::NotifyWebhookFailure.call(webhook: webhook, throttle_window: FAILURE_ALERT_THROTTLE_WINDOW)
  end

  def success_http_codes
    WebhookAttempt::SUCCESS_STATUS_CODES
  end
end
