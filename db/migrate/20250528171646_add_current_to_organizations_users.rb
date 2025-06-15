class AddCurrentToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations_users, :current, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          UPDATE organizations_users
          SET current = true
          FROM users
          WHERE organizations_users.user_id = users.id
          AND organizations_users.organization_id = users.current_organization_id
        SQL
      end
    end

    add_index :organizations_users, %i[user_id current], where: 'current = true'
  end
end
