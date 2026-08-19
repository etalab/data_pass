class AddAbandonedAtToWebhookAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :webhook_attempts, :abandoned_at, :datetime
  end
end
