class Developer::MarkWebhookAsValidated < ApplicationInteractor
  def call
    return unless context.webhook_test[:success]

    context.webhook.mark_as_valid!
    context.webhook.activate! if context.webhook_url_changed
  end
end
