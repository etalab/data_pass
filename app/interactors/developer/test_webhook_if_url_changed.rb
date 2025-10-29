class Developer::TestWebhookIfUrlChanged < ApplicationInteractor
  def call
    if context.webhook_url_changed
      test_result = Developer::TestWebhook.call(webhook: context.webhook)
      context.webhook_test = test_result.webhook_test
    else
      context.webhook_test = { success: true }
    end
  end
end
