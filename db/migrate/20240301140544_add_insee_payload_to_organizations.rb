class AddINSEEPayloadToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :insee_payload, :jsonb
    add_column :organizations, :last_insee_payload_updated_at, :datetime
  end
end
