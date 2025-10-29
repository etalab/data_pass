class Developer::MarkWebhookAsValidated < ApplicationInteractor
  def call
    return unless context.webhook_test[:success]

    context.webhook.mark_as_valid!
  end
end
