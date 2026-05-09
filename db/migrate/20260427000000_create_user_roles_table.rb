class CreateUserRolesTable < ActiveRecord::Migration[8.1]
  def up
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.references :data_provider, foreign_key: true
      t.string :data_provider_slug
      t.string :authorization_definition_id
      t.timestamps
    end

    add_index :user_roles,
      %i[user_id role data_provider_id authorization_definition_id],
      unique: true, nulls_not_distinct: true,
      name: 'idx_user_roles_unique'
    add_index :user_roles, %i[role data_provider_slug]
    add_index :user_roles, %i[role authorization_definition_id]

    migrate_existing_roles
  end

  def down
    drop_table :user_roles
  end

  private

  def migrate_existing_roles
    execute(<<~SQL.squish).each do |row|
      SELECT id, roles FROM users WHERE roles <> '{}'
    SQL
      migrate_user(row['id'], row['roles'])
    end
  end

  def migrate_user(user_id, pg_roles)
    pg_roles.delete('{}').split(',').map(&:strip).compact_blank.each do |role_string|
      migrate_role(user_id, role_string)
    end
  end

  def migrate_role(user_id, role_string)
    if role_string == 'admin'
      execute_insert(user_id, 'admin', nil, nil, nil)
    else
      parsed = ParsedRole.parse(role_string)
      return unless parsed.role

      provider_id = find_provider_id(parsed.provider_slug)
      def_id = parsed.fd_level? ? nil : parsed.definition_id

      execute_insert(user_id, parsed.role, provider_id, parsed.provider_slug, def_id)
    end
  end

  def execute_insert(user_id, role, provider_id, provider_slug, def_id)
    execute <<~SQL.squish
      INSERT INTO user_roles (user_id, role, data_provider_id, data_provider_slug, authorization_definition_id, created_at, updated_at)
      VALUES (
        #{user_id},
        #{quote(role)},
        #{provider_id || 'NULL'},
        #{provider_slug ? quote(provider_slug) : 'NULL'},
        #{def_id ? quote(def_id) : 'NULL'},
        NOW(), NOW()
      )
      ON CONFLICT DO NOTHING
    SQL
  end

  def find_provider_id(slug)
    return nil unless slug

    result = execute("SELECT id FROM data_providers WHERE slug = #{quote(slug)}").first
    result&.fetch('id', nil)
  end
end
