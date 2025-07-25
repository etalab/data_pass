class AddVerifiedToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations_users, :verified, :boolean, default: true, null: false
    add_column :organizations_users, :verified_reason, :string, default: 'from ProConnect identity', null: false
  end
end
