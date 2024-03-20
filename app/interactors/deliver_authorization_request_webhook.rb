class DeliverAuthorizationRequestWebhook < ApplicationInteractor
  def call
    DeliverAuthorizationRequestWebhookJob.perform_later(*job_params)
  end

  private

  def job_params
    [
      context.target_api,
      webhook_payload,
      context.authorization_request.id
    ]
  end

  def webhook_payload
    WebhookSerializer.new(
      context.authorization_request,
      'validated'
    ).serializable_hash
  end
end
