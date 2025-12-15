class FixDoubleEncodedWebhookAttemptsPayloads < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE webhook_attempts
      SET payload = (payload #>> '{}')::jsonb
      WHERE jsonb_typeof(payload) = 'string';
    SQL
  end

  def down; end
end
