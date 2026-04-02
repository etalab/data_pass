class AddDynSuffixToHabilitationTypeSlugs < ActiveRecord::Migration[8.1]
  ROLE_TYPES = %w[instructor manager developer reporter].freeze

  def up
    habilitation_types_without_dyn.each do |ht|
      old_slug = ht['slug']
      migrate_habilitation_type(old_slug, "#{old_slug}-dyn")
    end
  end

  def down
    habilitation_types_with_dyn.each do |ht|
      new_slug = ht['slug']
      migrate_habilitation_type(new_slug, new_slug.delete_suffix('-dyn'))
    end
  end

  private

  def migrate_habilitation_type(from_slug, to_slug)
    from_uid = from_slug.tr('-', '_')
    to_uid = to_slug.tr('-', '_')
    from_type = "AuthorizationRequest::#{from_uid.classify}"
    to_type = "AuthorizationRequest::#{to_uid.classify}"

    update_slug(from_slug, to_slug)
    update_sti_types(from_type, to_type)
    update_form_uid(from_uid, to_uid)
    update_user_roles(from_uid, to_uid)
    update_user_settings(from_uid, to_uid)
  end

  def habilitation_types_without_dyn
    execute("SELECT id, slug FROM habilitation_types WHERE slug NOT LIKE '%-dyn'").to_a
  end

  def habilitation_types_with_dyn
    execute("SELECT id, slug FROM habilitation_types WHERE slug LIKE '%-dyn'").to_a
  end

  def update_slug(from_slug, to_slug)
    execute(sanitize('UPDATE habilitation_types SET slug = ? WHERE slug = ?', to_slug, from_slug))
  end

  def update_sti_types(from_type, to_type)
    %w[authorization_requests authorizations instructor_draft_requests].each do |table|
      column = table == 'authorization_requests' ? 'type' : 'authorization_request_class'
      execute(sanitize("UPDATE #{table} SET #{column} = ? WHERE #{column} = ?", to_type, from_type))
    end
  end

  def update_form_uid(from_uid, to_uid)
    %w[authorization_requests authorizations instructor_draft_requests].each do |table|
      execute(sanitize("UPDATE #{table} SET form_uid = ? WHERE form_uid = ?", to_uid, from_uid))
    end
  end

  def update_user_roles(from_uid, to_uid)
    ROLE_TYPES.each do |role|
      execute(sanitize(
        'UPDATE users SET roles = array_replace(roles, ?, ?) WHERE ? = ANY(roles)',
        "#{from_uid}:#{role}", "#{to_uid}:#{role}", "#{from_uid}:#{role}"
      ))
    end
  end

  def update_user_settings(from_uid, to_uid)
    %w[submit_notifications messages_notifications].each do |setting|
      old_key = "instruction_#{setting}_for_#{from_uid}"
      new_key = "instruction_#{setting}_for_#{to_uid}"

      execute(sanitize(
        'UPDATE users SET settings = settings - ? || jsonb_build_object(?, settings->?) WHERE jsonb_exists(settings, ?)',
        old_key, new_key, old_key, old_key
      ))
    end
  end

  def sanitize(sql, *args)
    ActiveRecord::Base.sanitize_sql_array([sql, *args])
  end
end
