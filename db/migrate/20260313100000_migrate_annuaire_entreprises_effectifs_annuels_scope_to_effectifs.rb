class MigrateAnnuaireEntreprisesEffectifsAnnuelsScopeToEffectifs < ActiveRecord::Migration[8.1]
  OLD_SCOPE = 'effectifs_annuels'
  NEW_SCOPE = 'effectifs'

  def up
    migrate_authorization_requests
    migrate_authorizations
  end

  def down
    revert_authorization_requests
    revert_authorizations
  end

  private

  def migrate_authorization_requests
    annuaire_requests_with_old_scope.find_each do |request|
      update_scopes(request) { |scopes| (scopes - [OLD_SCOPE] + [NEW_SCOPE]).sort.uniq }
    end
  end

  def migrate_authorizations
    annuaire_authorizations_with_old_scope.find_each do |authorization|
      update_scopes(authorization) { |scopes| (scopes - [OLD_SCOPE] + [NEW_SCOPE]).sort.uniq }
    end
  end

  def revert_authorization_requests
    annuaire_requests_with_new_scope.find_each do |request|
      update_scopes(request) { |scopes| (scopes - [NEW_SCOPE] + [OLD_SCOPE]).sort.uniq }
    end
  end

  def revert_authorizations
    annuaire_authorizations_with_new_scope.find_each do |authorization|
      update_scopes(authorization) { |scopes| (scopes - [NEW_SCOPE] + [OLD_SCOPE]).sort.uniq }
    end
  end

  def old_scope_in_scopes_sql
    "EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s = '#{OLD_SCOPE}')"
  end

  def new_scope_in_scopes_sql
    "EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s = '#{NEW_SCOPE}')"
  end

  def annuaire_requests_with_old_scope
    AuthorizationRequest
      .where(type: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(old_scope_in_scopes_sql)
  end

  def annuaire_authorizations_with_old_scope
    Authorization
      .where(authorization_request_class: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(old_scope_in_scopes_sql)
  end

  def annuaire_requests_with_new_scope
    AuthorizationRequest
      .where(type: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(new_scope_in_scopes_sql)
  end

  def annuaire_authorizations_with_new_scope
    Authorization
      .where(authorization_request_class: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(new_scope_in_scopes_sql)
  end

  def update_scopes(record)
    scopes = parse_scopes(record.data['scopes'])
    new_scopes = yield scopes
    record.update_column(:data, record.data.merge('scopes' => new_scopes.to_json))
  end

  def parse_scopes(value)
    return [] if value.blank?

    Array(JSON.parse(value))
  rescue JSON::ParserError
    []
  end
end
