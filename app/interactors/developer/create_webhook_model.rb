class Developer::CreateWebhookModel < ApplicationInteractor
  def call
    secret = generate_secret
    context.secret = secret
    context.webhook = Webhook.new(webhook_params(secret))

    return if context.webhook.save

    context.fail!(error: :invalid_webhook_model)
  end

  private

  def webhook_params(secret)
    context.webhook_params.merge(
      secret: secret,
      validated: false,
      enabled: false
    )
  end

  def generate_secret
    SecureRandom.hex(32)
  end
end
