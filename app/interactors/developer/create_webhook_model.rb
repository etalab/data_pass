class Developer::CreateWebhookModel < ApplicationInteractor
  def call
    context.webhook = Webhook.new(webhook_params)

    return if context.webhook.save

    context.fail!(error: :invalid_webhook_model)
  end

  private

  def webhook_params
    context.webhook_params.merge(
      secret: generate_secret,
      validated: false,
      enabled: false
    )
  end

  def generate_secret
    SecureRandom.hex(32)
  end
end
