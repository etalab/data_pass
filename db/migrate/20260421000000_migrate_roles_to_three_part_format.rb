class MigrateRolesToThreePartFormat < ActiveRecord::Migration[8.1]
  def up
    migrate_user_roles
    migrate_admin_events
  end

  YAML_PROVIDER_MAP = {
    'api_entreprise' => 'dinum',
    'api_particulier' => 'dinum',
    'formulaire_qf' => 'dinum',
    'france_connect' => 'dinum',
    'hubee_cert_dc' => 'dgs',
    'hubee_dila' => 'dila',
    'le_taxi' => 'dinum',
    'pro_connect_service_provider' => 'dinum',
    'pro_connect_identity_provider' => 'dinum',
    'api_indicateurs_sociaux' => 'dinum',
    'annuaire_des_entreprises' => 'dinum',
    'api_impot_particulier' => 'dgfip',
    'api_impot_particulier_sandbox' => 'dgfip',
    'api_sfip' => 'dgfip',
    'api_sfip_sandbox' => 'dgfip',
    'api_hermes' => 'dgfip',
    'api_hermes_sandbox' => 'dgfip',
    'api_e_contacts' => 'dgfip',
    'api_e_contacts_sandbox' => 'dgfip',
    'api_opale' => 'dgfip',
    'api_opale_sandbox' => 'dgfip',
    'api_ocfi' => 'dgfip',
    'api_ocfi_sandbox' => 'dgfip',
    'api_e_pro' => 'dgfip',
    'api_e_pro_sandbox' => 'dgfip',
    'api_robf' => 'dgfip',
    'api_robf_sandbox' => 'dgfip',
    'api_cpr_pro_adelie' => 'dgfip',
    'api_cpr_pro_adelie_sandbox' => 'dgfip',
    'api_imprimfip' => 'dgfip',
    'api_imprimfip_sandbox' => 'dgfip',
    'api_satelit' => 'dgfip',
    'api_satelit_sandbox' => 'dgfip',
    'api_mire' => 'dgfip',
    'api_mire_sandbox' => 'dgfip',
    'api_ensu_documents' => 'dgfip',
    'api_ensu_documents_sandbox' => 'dgfip',
    'api_rial' => 'dgfip',
    'api_rial_sandbox' => 'dgfip',
    'api_infinoe' => 'dgfip',
    'api_infinoe_sandbox' => 'dgfip',
    'api_ficoba' => 'dgfip',
    'api_ficoba_sandbox' => 'dgfip',
    'api_r2p' => 'dgfip',
    'api_r2p_sandbox' => 'dgfip',
    'api_sfip_r2p' => 'dgfip',
    'api_sfip_r2p_sandbox' => 'dgfip',
    'api_droits_cnam' => 'cnam',
    'api_indemnites_journalieres_cnam' => 'cnam',
    'api_scolarite' => 'menj',
    'api_gfe_echange_collectivites' => 'menj',
    'api_gfe_echange_editeurs_restauration' => 'menj',
    'api_inser_jeunes_sup' => 'menj',
    'api_mobilic' => 'mtes',
    'api_gunenv' => 'mtes',
    'api_ingres' => 'cisirh',
    'services_cisirh' => 'cisirh',
    'api_declaration_auto_entrepreneur' => 'urssaf',
    'api_declaration_cesu' => 'urssaf',
    'api_captchetat' => 'aife',
    'api_pro_sante_connect' => 'ans',
  }.freeze

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

      new_roles = old_roles.map { |role_string| convert_role(role_string) }

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
    roles.map { |r| convert_role(r) }.to_json
  end

  def convert_role(role_string)
    role_string = role_string.strip
    return 'admin' if role_string == 'admin'

    parts = role_string.split(':')
    return role_string if parts.length == 3

    raise "Unexpected role format: #{role_string.inspect}" unless parts.length == 2

    def_id, role_type = parts
    provider_slug = find_provider_slug(def_id)

    raise "Cannot resolve provider for definition #{def_id.inspect} in role #{role_string.inspect}. Add it to YAML_PROVIDER_MAP." unless provider_slug

    "#{provider_slug}:#{def_id}:#{role_type}"
  end

  def find_provider_slug(definition_id)
    result = execute(<<~SQL.squish).first
      SELECT dp.slug FROM habilitation_types ht
      JOIN data_providers dp ON dp.id = ht.data_provider_id
      WHERE LOWER(REPLACE(ht.slug, '-', '_')) = #{quote(definition_id)}
    SQL
    return result['slug'] if result

    YAML_PROVIDER_MAP[definition_id]
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
