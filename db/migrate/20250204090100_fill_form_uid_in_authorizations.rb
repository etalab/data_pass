class FillFormUidInAuthorizations < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL.squish
      UPDATE authorizations
      SET form_uid = authorization_requests.form_uid
      FROM authorization_requests
      WHERE authorizations.request_id = authorization_requests.id;
    SQL
  end
end
