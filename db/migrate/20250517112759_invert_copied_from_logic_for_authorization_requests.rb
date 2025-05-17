class InvertCopiedFromLogicForAuthorizationRequests < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      /* Ajouter la nouvelle colonne copied_from_request_id */
      ALTER TABLE authorization_requests 
      ADD COLUMN copied_from_request_id INTEGER;

      /* Ajouter l'index sur la nouvelle colonne */
      CREATE INDEX idx_authorization_requests_copied_from_request_id 
      ON authorization_requests(copied_from_request_id);

      /* Remplir la nouvelle colonne avec les données inversées */
      UPDATE authorization_requests ar_target
      SET copied_from_request_id = ar_source.id
      FROM authorization_requests ar_source
      WHERE ar_source.next_request_copied_id = ar_target.id;

      /* Ajouter la clé étrangère */
      ALTER TABLE authorization_requests
      ADD CONSTRAINT fk_authorization_requests_copied_from_request
      FOREIGN KEY (copied_from_request_id) 
      REFERENCES authorization_requests(id) 
      ON DELETE SET NULL;

      /* Supprimer l'ancienne clé étrangère si elle existe */
      ALTER TABLE authorization_requests
      DROP CONSTRAINT IF EXISTS fk_rails_dd7d33b0d8;

      /* Supprimer l'ancien index s'il existe */
      DROP INDEX IF EXISTS index_authorization_requests_on_next_request_copied_id;

      /* Supprimer l'ancienne colonne */
      ALTER TABLE authorization_requests
      DROP COLUMN next_request_copied_id;
    SQL
  end

  def down
    execute <<-SQL
      /* Ajouter l'ancienne colonne next_request_copied_id */
      ALTER TABLE authorization_requests 
      ADD COLUMN next_request_copied_id INTEGER;

      /* Ajouter l'index sur l'ancienne colonne */
      CREATE INDEX index_authorization_requests_on_next_request_copied_id 
      ON authorization_requests(next_request_copied_id);

      /* Remplir l'ancienne colonne avec les données inversées */
      UPDATE authorization_requests ar_source
      SET next_request_copied_id = ar_target.id
      FROM authorization_requests ar_target
      WHERE ar_target.copied_from_request_id = ar_source.id;

      /* Ajouter la clé étrangère */
      ALTER TABLE authorization_requests
      ADD CONSTRAINT fk_rails_dd7d33b0d8
      FOREIGN KEY (next_request_copied_id) 
      REFERENCES authorization_requests(id) 
      ON DELETE SET NULL;

      /* Supprimer la nouvelle clé étrangère */
      ALTER TABLE authorization_requests
      DROP CONSTRAINT IF EXISTS fk_authorization_requests_copied_from_request;

      /* Supprimer le nouvel index */
      DROP INDEX IF EXISTS idx_authorization_requests_copied_from_request_id;

      /* Supprimer la nouvelle colonne */
      ALTER TABLE authorization_requests
      DROP COLUMN copied_from_request_id;
    SQL
  end
end