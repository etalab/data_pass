class AddCurrentOrganizationIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :current_organization_id, :integer, null: true

    add_index :users, :current_organization_id
  end
end
