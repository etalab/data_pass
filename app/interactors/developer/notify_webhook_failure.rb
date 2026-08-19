class Developer::NotifyWebhookFailure < ApplicationInteractor
  def call
    return unless alert_slot_claimed?

    WebhookMailer.with(webhook: webhook).fail.deliver_later
  end

  private

  def alert_slot_claimed?
    claimed = false

    webhook.with_lock do
      next if webhook.failure_alert_throttled?(context.throttle_window)

      webhook.update!(last_failure_alert_sent_at: Time.current)
      claimed = true
    end

    claimed
  end

  def webhook
    context.webhook
  end
end
