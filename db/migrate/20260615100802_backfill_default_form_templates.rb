class BackfillDefaultFormTemplates < ActiveRecord::Migration[8.1]
  def up
    execute(<<~SQL.squish)
      INSERT INTO form_templates (habilitation_type_id, slug, "default", created_at, updated_at)
      SELECT ht.id, ht.slug, true, NOW(), NOW()
      FROM habilitation_types ht
      WHERE NOT EXISTS (
        SELECT 1 FROM form_templates ft
        WHERE ft.habilitation_type_id = ht.id AND ft."default" = true
      )
    SQL
  end

  def down
    # Backfill non réversible : impossible de distinguer les defaults créés ici
    # de ceux créés depuis (callback ensure_default_form_template! ou admin).
  end
end
