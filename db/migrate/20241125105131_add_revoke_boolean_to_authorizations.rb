class AddRevokeBooleanToAuthorizations < ActiveRecord::Migration[8.0]
  def up
    add_column :authorizations, :revoked, :boolean, default: false

    Authorization.joins(:request).where(authorization_requests: { state: 'revoked' }).update_all(revoked: true)
  end

  def down
    remove_column :authorizations, :revoked
  end
end
