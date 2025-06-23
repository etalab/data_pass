class TrimAndDowncaseEmailsInHstore < ActiveRecord::Migration[8.0]
  def up
    # Update authorization_requests table
    execute <<-SQL
      UPDATE authorization_requests
      SET data = data || (
        SELECT hstore(array_agg(key), array_agg(LOWER(TRIM(value))))
        FROM each(data)
        WHERE key LIKE '%_email'
      )
      WHERE EXISTS (
        SELECT 1 FROM each(data) WHERE key LIKE '%_email'
      );
    SQL

    # Update authorizations table
    execute <<-SQL
      UPDATE authorizations
      SET data = data || (
        SELECT hstore(array_agg(key), array_agg(LOWER(TRIM(value))))
        FROM each(data)
        WHERE key LIKE '%_email'
      )
      WHERE EXISTS (
        SELECT 1 FROM each(data) WHERE key LIKE '%_email'
      );
    SQL
  end

  def down
    # Silently allow rollback - data transformation cannot be reversed
  end
end
