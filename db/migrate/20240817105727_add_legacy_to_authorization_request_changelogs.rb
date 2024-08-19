class AddLegacyToAuthorizationRequestChangelogs < ActiveRecord::Migration[7.2]
  def up
    add_column :authorization_request_changelogs, :legacy, :boolean, default: false

    AuthorizationRequestChangelog.update_all(legacy: true)
  end

  def down
    remove_column :authorization_request_changelogs, :legacy
  end
end
