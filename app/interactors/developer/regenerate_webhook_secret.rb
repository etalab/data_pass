class Developer::RegenerateWebhookSecret < ApplicationInteractor
  def call
    secret = generate_secret
    context.secret = secret

    context.webhook.assign_attributes(
      secret: secret
    )

    return if context.webhook.save

    context.fail!(error: :invalid_webhook_model)
  end

  private

  def generate_secret
    SecureRandom.hex(32)
  end
end
