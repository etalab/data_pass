class Developer::EnableWebhook < ApplicationInteractor
  def call
    test_webhook!

    webhook.mark_as_valid! unless webhook.validated?
    webhook.activate!
  end

  private

  def test_webhook!
    test_result = Developer::TestWebhook.call(webhook: webhook)

    context.webhook_test = test_result.webhook_test

    return if test_result.webhook_test[:success]

    context.fail!(error: :webhook_validation_failed)
  end

  def webhook
    context.webhook
  end
end
