class AddIndexToOrganizationsOnDenominationUniteLegale < ActiveRecord::Migration[7.2]
  def change
    add_index :organizations,
      "(insee_payload->'etablissement'->'uniteLegale'->>'denominationUniteLegale')",
      name: 'index_organizations_on_denomination_unite_legale'
  end
end
