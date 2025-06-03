class AddProconnectPayloadToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :proconnect_payload, :jsonb, default: {}
    add_column :organizations, :last_proconnect_updated_at, :datetime
  end
end
