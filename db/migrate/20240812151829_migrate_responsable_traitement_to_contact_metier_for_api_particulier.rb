class MigrateResponsableTraitementToContactMetierForAPIParticulier < ActiveRecord::Migration[7.2]
  def up
    execute hstore_keys_migration(keys)
  end

  def down
    execute hstore_keys_migration(keys.map(&:reverse))
  end

  private

  def hstore_keys_migration(keys)
    <<~SQL
      CREATE TEMP TABLE key_mapping (old_key text, new_key text);

      INSERT INTO key_mapping VALUES
        #{keys.map { |old_key, new_key| "('#{old_key}', '#{new_key}')" }.join(",\n")}
      ;

      SELECT * FROM authorization_requests;

      UPDATE authorization_requests
      SET data = (
          SELECT hstore(array_agg(COALESCE(km.new_key, k)), array_agg(data->k))
          FROM skeys(data) k
          LEFT JOIN key_mapping km ON km.old_key = k
      )
      WHERE type = 'AuthorizationRequest::APIParticulier';

      DROP TABLE key_mapping;
    SQL
  end

  def keys
    AuthorizationRequest.contact_attributes.each_with_object([]) do |key, array|
      array << %w[responsable_traitement contact_metier].map do |prefix|
        "#{prefix}_#{key}"
      end
    end
  end
end
