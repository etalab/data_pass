class MigrateRolesToThreePartFormat < ActiveRecord::Migration[8.1]
  def up
    migrate_user_roles
    migrate_admin_events
  end

  def down
    revert_user_roles
    revert_admin_events
  end

  private

  def migrate_user_roles
    execute(<<~SQL.squish).each do |row|
      SELECT id, roles FROM users WHERE roles <> '{}'
    SQL
      user_id = row['id']
      old_roles = parse_pg_array(row['roles'])

      new_roles = old_roles.filter_map { |role_string| convert_role(role_string) }

      escaped = new_roles.map { |r| quote(r) }.join(',')
      sql_array = new_roles.any? ? "ARRAY[#{escaped}]" : 'ARRAY[]::varchar[]'
      execute("UPDATE users SET roles = #{sql_array} WHERE id = #{user_id}")
    end
  end

  def migrate_admin_events
    execute(<<~SQL.squish).each do |row|
      SELECT id, before_attributes, after_attributes
      FROM admin_events
      WHERE name = 'user_roles_changed' AND before_attributes::jsonb ? 'roles'
    SQL
      convert_admin_event(row)
    end
  end

  def convert_admin_event(row)
    new_before = convert_roles_json(row['before_attributes'])
    new_after = convert_roles_json(row['after_attributes'])

    execute(<<~SQL.squish)
      UPDATE admin_events
      SET before_attributes = jsonb_set(before_attributes::jsonb, '{roles}', #{quote(new_before)}::jsonb)::json,
          after_attributes = jsonb_set(after_attributes::jsonb, '{roles}', #{quote(new_after)}::jsonb)::json
      WHERE id = #{row['id']}
    SQL
  end

  def convert_roles_json(json_string)
    roles = JSON.parse(json_string)['roles'] || []
    roles.filter_map { |r| convert_role(r) }.to_json
  end

  def convert_role(role_string)
    role_string = role_string.strip
    return 'admin' if role_string == 'admin'

    parts = role_string.split(':')
    return role_string if parts.length == 3

    raise "Unexpected role format: #{role_string.inspect}" unless parts.length == 2

    def_id, role_type = parts
    provider_slug = find_provider_slug(def_id)

    unless provider_slug
      say "Orphaned role #{role_string.inspect} (definition #{def_id.inspect} not found) — removing"
      return nil
    end

    "#{provider_slug}:#{def_id}:#{role_type}"
  end

  def find_provider_slug(definition_id)
    AuthorizationDefinition.find_by(id: definition_id)&.provider_slug
  end

  def parse_pg_array(pg_string)
    pg_string.delete('{}').split(',').map(&:strip).compact_blank
  end

  def revert_user_roles
    execute(<<~SQL.squish).each do |row|
      SELECT id, roles FROM users WHERE roles <> '{}'
    SQL
      user_id = row['id']
      old_roles = parse_pg_array(row['roles'])

      new_roles = old_roles.map { |r| revert_role(r) }

      escaped = new_roles.map { |r| quote(r) }.join(',')
      sql_array = new_roles.any? ? "ARRAY[#{escaped}]" : 'ARRAY[]::varchar[]'
      execute("UPDATE users SET roles = #{sql_array} WHERE id = #{user_id}")
    end
  end

  def revert_admin_events
    execute(<<~SQL.squish).each do |row|
      SELECT id, before_attributes, after_attributes
      FROM admin_events
      WHERE name = 'user_roles_changed' AND before_attributes::jsonb ? 'roles'
    SQL
      revert_admin_event(row)
    end
  end

  def revert_admin_event(row)
    new_before = revert_roles_json(row['before_attributes'])
    new_after = revert_roles_json(row['after_attributes'])

    execute(<<~SQL.squish)
      UPDATE admin_events
      SET before_attributes = jsonb_set(before_attributes::jsonb, '{roles}', #{quote(new_before)}::jsonb)::json,
          after_attributes = jsonb_set(after_attributes::jsonb, '{roles}', #{quote(new_after)}::jsonb)::json
      WHERE id = #{row['id']}
    SQL
  end

  def revert_roles_json(json_string)
    roles = JSON.parse(json_string)['roles'] || []
    roles.map { |r| revert_role(r) }.to_json
  end

  def revert_role(role_string)
    return 'admin' if role_string == 'admin'

    parts = role_string.split(':')
    return role_string unless parts.length == 3

    "#{parts[1]}:#{parts[2]}"
  end
end
