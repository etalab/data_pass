class DeliverAuthorizationRequestWebhookJob < ApplicationJob
  include KeepTrackOfJobAttempts

  THRESHOLD_TO_NOTIFY_DATA_PROVIDER = 5

  class WebhookDeliveryFailedError < StandardError; end

  retry_on(WebhookDeliveryFailedError, wait: :polynomially_longer, attempts: :unlimited)

  def perform(authorization_request_kind, json, authorization_request_id)
    return if webhook_url(authorization_request_kind).blank?
    return if verify_token(authorization_request_kind).blank?

    payload = JSON.parse(json)

    response = request(authorization_request_kind, payload)

    if success_http_codes.include?(response.status)
      handle_success(response.body, authorization_request_id)
    else
      handle_error(response, authorization_request_kind, payload, authorization_request_id)
    end
  end

  private

  def request(authorization_request_kind, payload)
    Faraday.new(webhook_uri(authorization_request_kind).to_s).post(webhook_uri(authorization_request_kind).path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-Hub-Signature-256'] = "sha256=#{generate_hub_signature(authorization_request_kind, payload)}"
      req.headers['X-App-Environment'] = Rails.env
      req.body = payload.to_json
    end
  end

  def handle_success(payload, authorization_request_id)
    json = JSON.parse(payload)

    return unless json && json['token_id'].present?

    authorization_request = AuthorizationRequest.find(authorization_request_id)
    authorization_request.update(
      external_provider_id: json['token_id']
    )
  rescue JSON::ParserError
    nil
  end

  def handle_error(response, authorization_request_kind, payload, _authorization_request_id)
    track_error(response, authorization_request_kind, payload)
    notify_webhook_fail(authorization_request_kind, payload, response) if attempts == THRESHOLD_TO_NOTIFY_DATA_PROVIDER
    webhook_fail!
  end

  def webhook_fail!
    raise WebhookDeliveryFailedError
  end

  def track_error(response, authorization_request_kind, payload)
    Sentry.set_extras(
      {
        authorization_request_kind:,
        payload:,
        tries_count: attempts,
        webhook_response_status: response.status,
        webhook_response_body: response.body
      }
    )

    Sentry.capture_message("Fail to call target's api webhook endpoint")
  end

  def notify_webhook_fail(authorization_request_kind, payload, response)
    WebhookMailer.with(
      authorization_request_kind:,
      payload:,
      webhook_response_status: response.status.to_i,
      webhook_response_body: response.body.to_s
    ).fail.deliver_later
  end

  def generate_hub_signature(authorization_request_kind, payload)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      verify_token(authorization_request_kind),
      payload.to_json
    )
  end

  def webhook_uri(authorization_request_kind)
    URI(webhook_url(authorization_request_kind))
  end

  def webhook_url(authorization_request_kind)
    Rails.application.credentials.webhooks.public_send(authorization_request_kind)&.url
  end

  def verify_token(authorization_request_kind)
    Rails.application.credentials.webhooks.public_send(authorization_request_kind)&.token
  end

  def success_http_codes
    [
      200,
      201,
      204
    ]
  end
end
