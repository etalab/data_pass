class DeliverAuthorizationRequestWebhookJob < ApplicationJob
  TOTAL_ATTEMPTS = 5

  class WebhookDeliveryFailedError < StandardError; end

  retry_on(WebhookDeliveryFailedError, wait: :polynomially_longer, attempts: :unlimited)

  def serialize
    super.merge('tries_count' => (@attempts || 1) + 1)
  end

  def deserialize(job_data)
    super
    @attempts = job_data['tries_count']
  end

  def perform(target_api, json, authorization_request_id)
    return if webhook_url(target_api).blank?
    return if verify_token(target_api).blank?

    payload = JSON.parse(json)

    response = request(target_api, payload)

    if success_http_codes.include?(response.status)
      handle_success(response.body, authorization_request_id)
    else
      handle_error(response, target_api, payload, authorization_request_id)
    end
  end

  private

  def request(target_api, payload)
    Faraday.new(webhook_uri(target_api).to_s).post(webhook_uri(target_api).path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-Hub-Signature-256'] = "sha256=#{generate_hub_signature(target_api, payload)}"
      req.body = payload.to_json
    end
  end

  def handle_success(payload, authorization_request_id)
    json = JSON.parse(payload)

    return unless json && json['token_id'].present?

    authorization_request = AuthorizationRequest.find(authorization_request_id)
    authorization_request.update(
      linked_token_manager_id: json['token_id']
    )
  rescue JSON::ParserError
    nil
  end

  def handle_error(response, target_api, payload, _authorization_request_id)
    track_error(response, target_api, payload)
    notify_webhook_fail(target_api, payload, response) if attempts == TOTAL_ATTEMPTS
    webhook_fail!
  end

  attr_reader :attempts

  def webhook_fail!
    raise WebhookDeliveryFailedError
  end

  def track_error(response, target_api, payload)
    Sentry.set_extras(
      {
        target_api:,
        payload:,
        tries_count: attempts,
        webhook_response_status: response.status,
        webhook_response_body: response.body
      }
    )

    Sentry.capture_message("Fail to call target's api webhook endpoint")
  end

  def notify_webhook_fail(target_api, payload, response)
    WebhookMailer.with(
      target_api:,
      payload:,
      webhook_response_status: response.status.to_i,
      webhook_response_body: response.body.to_s
    ).fail.deliver_later
  end

  def generate_hub_signature(target_api, payload)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      verify_token(target_api),
      payload.to_json
    )
  end

  def webhook_uri(target_api)
    URI(webhook_url(target_api))
  end

  def webhook_url(target_api)
    Rails.application.credentials.webhooks.public_send(target_api)&.url
  end

  def verify_token(target_api)
    Rails.application.credentials.webhooks.public_send(target_api)&.token
  end

  def success_http_codes
    [
      200,
      201,
      204
    ]
  end
end
