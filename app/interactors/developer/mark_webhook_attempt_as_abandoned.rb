class Developer::MarkWebhookAttemptAsAbandoned < ApplicationInteractor
  def call
    return if context.webhook_attempt.blank?

    context.webhook_attempt.update!(abandoned_at: Time.current)
  end
end
