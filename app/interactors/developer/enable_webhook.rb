class Developer::EnableWebhook < ApplicationInteractor
  def call
    test_webhook_if_not_validated

    context.fail!(error: :webhook_validation_failed) unless context.webhook.validated?

    context.webhook.activate!
  end

  private

  def test_webhook_if_not_validated
    return if context.webhook.validated?

    test_result = Developer::TestWebhook.call(webhook: context.webhook)

    if test_result.webhook_test[:success]
      context.webhook.mark_as_valid!
    else
      context.webhook_test = test_result.webhook_test
    end
  end
end
