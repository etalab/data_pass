class FixDynFormUidsAfterSlugSuffixMigration < ActiveRecord::Migration[8.1]
  def up
    dyn_habilitation_types.each do |slug|
      sti_class = "AuthorizationRequest::#{slug.tr('-', '_').classify}"

      execute(sanitize(
        'UPDATE authorization_requests SET form_uid = ? WHERE type = ? AND form_uid != ?',
        slug, sti_class, slug
      ))

      execute(sanitize(
        'UPDATE authorizations SET form_uid = ? WHERE authorization_request_class = ? AND form_uid != ?',
        slug, sti_class, slug
      ))

      execute(sanitize(
        'UPDATE instructor_draft_requests SET form_uid = ? WHERE authorization_request_class = ? AND form_uid != ?',
        slug, sti_class, slug
      ))
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

  def sanitize(sql, *args)
    ActiveRecord::Base.sanitize_sql_array([sql, *args])
  end
end
