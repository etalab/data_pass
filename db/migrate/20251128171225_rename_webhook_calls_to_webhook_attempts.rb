class RenameWebhookCallsToWebhookAttempts < ActiveRecord::Migration[8.1]
  def change
    rename_table :webhook_calls, :webhook_attempts
  end
end
