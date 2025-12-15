class Developer::UpdateWebhookModel < ApplicationInteractor
  def call
    context.webhook.assign_attributes(webhook_params)

    return if context.webhook.save

    context.fail!(error: :invalid_webhook_model)
  end

  private

  def webhook_params
    context.webhook_params
  end
end
