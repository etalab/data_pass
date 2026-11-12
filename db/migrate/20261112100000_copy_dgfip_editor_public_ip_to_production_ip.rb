class CopyDGFIPEditorPublicIpToProductionIp < ActiveRecord::Migration[8.1]
  EDITOR_FORM_UID_PATTERNS = %w[
    api-sfip-%editeur
    api-impot-particulier-%editeur
    api-rial-%editeur
    api-infinoe-%editeur
    api-ficoba-%editeur
  ].freeze

  TABLES = %w[authorization_requests authorizations instructor_draft_requests].freeze

  def up
    TABLES.each do |table|
      execute <<~SQL.squish
        UPDATE #{table}
        SET data = data || hstore('adresse_ip_publique_production', data -> 'adresse_ip_publique')
        WHERE form_uid LIKE ANY (ARRAY[#{patterns_sql}])
          AND COALESCE(data -> 'adresse_ip_publique', '') <> ''
          AND COALESCE(data -> 'adresse_ip_publique_production', '') = ''
      SQL
    end
  end

  def down; end

  private

  def patterns_sql
    EDITOR_FORM_UID_PATTERNS.map { |pattern| connection.quote(pattern) }.join(', ')
  end
end
