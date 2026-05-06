class FixDynFormUidsAfterSlugSuffixMigration < ActiveRecord::Migration[8.1]
  ROLE_TYPES = %w[reporter instructor manager developer].freeze
  SETTING_PREFIXES = %w[
    instruction_submit_notifications_for
    instruction_messages_notifications_for
  ].freeze

  def up
    dyn_habilitation_types.each do |slug|
      sti_class = "AuthorizationRequest::#{slug.tr('-', '_').classify}"
      canonical_def_id = slug.tr('-', '_')
      stale_def_ids = stale_def_id_candidates(canonical_def_id, slug)

      fix_form_uid(slug, sti_class)
      fix_user_roles(canonical_def_id, stale_def_ids)
      fix_user_settings(canonical_def_id, stale_def_ids)
    end
  end

  def down
    # No-op : the previous state was inconsistent (some records hyphenated, others
    # underscored, none aligned with the static AuthorizationRequestForm uids).
  end

  private

  def dyn_habilitation_types
    execute("SELECT slug FROM habilitation_types WHERE slug LIKE '%-dyn'").to_a.map { |row| row['slug'] }
  end

  def stale_def_id_candidates(canonical_def_id, slug)
    [
      canonical_def_id.delete_suffix('_dyn'), # "test_test"   — pre-suffix-migration form
      slug,                                   # "test-test-dyn" — hyphenated final form
      slug.delete_suffix('-dyn'),             # "test-test"   — pre-suffix-migration hyphenated
    ].uniq.reject { |s| s == canonical_def_id || s.empty? }
  end

  def fix_form_uid(slug, sti_class)
    %w[authorization_requests authorizations instructor_draft_requests].each do |table|
      column = table == 'authorization_requests' ? 'type' : 'authorization_request_class'
      execute(sanitize(
        "UPDATE #{table} SET form_uid = ? WHERE #{column} = ? AND form_uid != ?",
        slug, sti_class, slug
      ))
    end
  end

  def fix_user_roles(canonical_def_id, stale_def_ids)
    stale_def_ids.each do |stale|
      pattern = "^([^:]+):#{Regexp.escape(stale)}:([^:]+)$"
      replacement = "\\1:#{canonical_def_id}:\\2"

      execute(sanitize(<<~SQL.squish, pattern, replacement, "%:#{stale}:%"))
        UPDATE users
        SET roles = (
          SELECT array_agg(regexp_replace(r, ?, ?))
          FROM unnest(roles) AS r
        )
        WHERE EXISTS (SELECT 1 FROM unnest(roles) r WHERE r LIKE ?)
      SQL
    end
  end

  def fix_user_settings(canonical_def_id, stale_def_ids)
    stale_def_ids.each do |stale|
      SETTING_PREFIXES.each do |prefix|
        old_key = "#{prefix}_#{stale}"
        new_key = "#{prefix}_#{canonical_def_id}"

        execute(sanitize(<<~SQL.squish, old_key, new_key, old_key, old_key))
          UPDATE users
          SET settings = (settings - ?) || jsonb_build_object(?, settings -> ?)
          WHERE jsonb_exists(settings, ?)
        SQL
      end
    end
  end

  def sanitize(sql, *args)
    ActiveRecord::Base.sanitize_sql_array([sql, *args])
  end
end
