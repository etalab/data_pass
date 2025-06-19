class DowncaseTrimVerifiedEmails < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE verified_emails
      SET email = LOWER(TRIM(email))
      WHERE email != LOWER(TRIM(email))
    SQL
  end

  def down; end
end
