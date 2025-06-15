class AddIdentityFederatorToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations_users, :identity_federator, :string, null: false, default: 'mon_compte_pro'
  end
end
