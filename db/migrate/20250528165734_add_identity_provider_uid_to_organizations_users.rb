class AddIdentityProviderUidToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations_users, :identity_provider_uid, :string
    add_column :organizations_users, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :organizations_users, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    # Set identity_provider_uid for existing records
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE organizations_users
          SET identity_provider_uid = '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
        SQL
      end
    end

    change_column_null :organizations_users, :identity_provider_uid, false
  end
end
