class MakeMonCompteProFieldsOptionalInOrganizations < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organizations, :mon_compte_pro_payload, true
    change_column_null :organizations, :last_mon_compte_pro_updated_at, true
  end
end
