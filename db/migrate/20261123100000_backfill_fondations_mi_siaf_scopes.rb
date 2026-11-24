class BackfillFondationsMiSiafScopes < ActiveRecord::Migration[8.1]
  USE_CASE_FORM_UIDS = %w[
    api-entreprise-socle-de-base
    api-entreprise-marches-publics
    api-entreprise-aides-publiques
    api-entreprise-subventions-associations
    api-entreprise-detection-fraude
  ].freeze

  ACCOUNTS_FORM_UIDS = (USE_CASE_FORM_UIDS - %w[api-entreprise-socle-de-base]).freeze

  def up = backfills.each(&:up)
  def down = backfills.reverse_each(&:down)

  private

  def backfills
    [
      backfill('fondations_mi_siaf', USE_CASE_FORM_UIDS),
      backfill('fondations_mi_siaf_comptes', ACCOUNTS_FORM_UIDS)
    ]
  end

  def backfill(added_scope, form_uids)
    ScopeBackfillService.new(
      %w[AuthorizationRequest::APIEntreprise],
      added_scope:,
      when_any_of: api_entreprise_scopes - [added_scope],
      form_uids:
    )
  end

  def api_entreprise_scopes
    AuthorizationDefinition.find('api_entreprise').scopes.map(&:value)
  end
end
