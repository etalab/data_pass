class MigrateAnnuaireEntreprisesConformiteScopeToConformiteFiscaleSociale < ActiveRecord::Migration[8.1]
  OLD_SCOPE = 'conformite'
  NEW_SCOPES = %w[conformite_fiscale conformite_sociale].freeze

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
    annuaire_requests_with_conformite.find_each do |request|
      update_scopes(request) { |scopes| replace_conformite_with_split(scopes) }
    end
  end

  def migrate_authorizations
    annuaire_authorizations_with_conformite.find_each do |authorization|
      update_scopes(authorization) { |scopes| replace_conformite_with_split(scopes) }
    end
  end

  def revert_authorization_requests
    annuaire_requests_with_split_scopes.find_each do |request|
      update_scopes(request) { |scopes| merge_split_back_to_conformite(scopes) }
    end
  end

  def revert_authorizations
    annuaire_authorizations_with_split_scopes.find_each do |authorization|
      update_scopes(authorization) { |scopes| merge_split_back_to_conformite(scopes) }
    end
  end

  def conformite_in_scopes_sql
    "EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s = '#{OLD_SCOPE}')"
  end

  def split_scopes_in_scopes_sql
    "EXISTS (SELECT 1 FROM jsonb_array_elements_text((data->'scopes')::jsonb) AS s WHERE s IN ('#{NEW_SCOPES.join("','")}'))"
  end

  def annuaire_requests_with_conformite
    AuthorizationRequest
      .where(type: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(conformite_in_scopes_sql)
  end

  def annuaire_authorizations_with_conformite
    Authorization
      .where(authorization_request_class: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(conformite_in_scopes_sql)
  end

  def annuaire_requests_with_split_scopes
    AuthorizationRequest
      .where(type: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(split_scopes_in_scopes_sql)
  end

  def annuaire_authorizations_with_split_scopes
    Authorization
      .where(authorization_request_class: 'AuthorizationRequest::AnnuaireDesEntreprises')
      .where("data ? 'scopes'")
      .where(split_scopes_in_scopes_sql)
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

  def replace_conformite_with_split(scopes)
    (scopes - [OLD_SCOPE] + NEW_SCOPES).sort.uniq
  end

  def merge_split_back_to_conformite(scopes)
    (scopes - NEW_SCOPES + [OLD_SCOPE]).sort.uniq
  end
end
