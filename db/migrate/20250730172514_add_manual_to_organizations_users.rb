class AddManualToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations_users, :manual, :boolean, default: false, null: false
  end
end
