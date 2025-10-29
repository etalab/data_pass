class Developer::DisableWebhook < ApplicationInteractor
  def call
    return unless should_disable?

    context.webhook.deactivate!
  end

  private

  def should_disable?
    context.webhook_url_changed
  end
end
