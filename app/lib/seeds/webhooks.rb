class Seeds::Webhooks
  def initialize(_context); end

  def perform
    create_api_entreprise_webhooks
  end

  private

  def create_api_entreprise_webhooks
    webhook_valid = Webhook.create!(
      authorization_definition_id: 'api_entreprise',
      url: 'http://localhost:3000/dummy/valid/webhooks',
      secret: SecureRandom.hex(32),
      events: %w[create update submit approve refuse revoke],
      validated: true,
      enabled: true
    )

    webhook_invalid = Webhook.create!(
      authorization_definition_id: 'api_entreprise',
      url: 'http://localhost:3000/dummy/invalid/webhooks',
      secret: SecureRandom.hex(32),
      events: %w[submit approve refuse],
      validated: false,
      enabled: false
    )

    create_webhook_attempts_for_api_entreprise(webhook_valid, webhook_invalid)
  end

  def create_webhook_attempts_for_api_entreprise(webhook_valid, webhook_invalid)
    authorization_requests = AuthorizationRequest.where(form_uid: 'api-entreprise').limit(5)

    authorization_requests.each_with_index do |authorization_request, index|
      create_successful_webhook_attempts(webhook_valid, webhook_invalid, authorization_request, index)
    end

    create_failed_webhook_attempts(webhook_valid, authorization_requests.first)
  end

  def create_successful_webhook_attempts(webhook_valid, webhook_invalid, authorization_request, index)
    WebhookAttempt.create!(
      webhook: webhook_valid,
      authorization_request: authorization_request,
      event_name: 'submit',
      status_code: 200,
      response_body: '{"token_id":"abc123"}',
      payload: { event: 'submit', id: authorization_request.id },
      created_at: index.days.ago
    )

    WebhookAttempt.create!(
      webhook: webhook_invalid,
      authorization_request: authorization_request,
      event_name: 'approve',
      status_code: 422,
      response_body: '{"hello":"world"}',
      payload: { event: 'approve', id: authorization_request.id },
      created_at: index.days.ago
    )
  end

  def create_failed_webhook_attempts(webhook, authorization_request)
    return unless authorization_request

    WebhookAttempt.create!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: 'update',
      status_code: 500,
      response_body: '{"error":"Internal server error"}',
      payload: { event: 'update', id: authorization_request.id },
      created_at: 1.hour.ago
    )

    WebhookAttempt.create!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: 'update',
      status_code: 404,
      response_body: '{"error":"Not found"}',
      payload: { event: 'update', id: authorization_request.id },
      created_at: 30.minutes.ago
    )
  end
end
