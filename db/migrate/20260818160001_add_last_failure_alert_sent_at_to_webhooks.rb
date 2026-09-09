class AddLastFailureAlertSentAtToWebhooks < ActiveRecord::Migration[8.1]
  def change
    add_column :webhooks, :last_failure_alert_sent_at, :datetime
  end
end
