class AddReadWebhooksScopeToOauthApplications < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      UPDATE oauth_applications
      SET scopes = scopes || ' read_webhooks', updated_at = NOW()
      WHERE scopes <> ''
        AND scopes NOT LIKE '%read_webhooks%'
    SQL
  end

  def down
    # Élargissement non réversible : impossible de distinguer les applications
    # dont le scope a été ajouté ici de celles qui l'avaient déjà (rattrapage
    # manuel sur staging le 03/09). Le retirer leur ferait perdre un accès.
  end
end
