class DowncaseTrimVerifiedEmails < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      DELETE FROM verified_emails
      WHERE id IN (
        SELECT id FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY LOWER(TRIM(email))
                   ORDER BY
                     CASE WHEN status = 'whitelisted' THEN 0 ELSE 1 END,
                     created_at ASC
                 ) as row_num
          FROM verified_emails
        ) ranked
        WHERE row_num > 1
      )
    SQL

    execute <<~SQL
      UPDATE verified_emails
      SET email = LOWER(TRIM(email))
      WHERE email != LOWER(TRIM(email))
    SQL
  end

  def down;end
end
