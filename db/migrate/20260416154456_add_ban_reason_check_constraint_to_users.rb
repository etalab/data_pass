class AddBanReasonCheckConstraintToUsers < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      ALTER TABLE users
      ADD CONSTRAINT ban_reason_required_when_banned
      CHECK (banned_at IS NULL OR (ban_reason IS NOT NULL AND ban_reason <> ''));
    SQL
  end

  def down
    execute <<~SQL.squish
      ALTER TABLE users
      DROP CONSTRAINT ban_reason_required_when_banned;
    SQL
  end
end
