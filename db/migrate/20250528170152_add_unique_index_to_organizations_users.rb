class AddUniqueIndexToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    # Remove duplicates before adding unique index
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          DELETE FROM organizations_users
          WHERE ctid NOT IN (
            SELECT MIN(ctid)
            FROM organizations_users
            GROUP BY organization_id, user_id
          )
        SQL
      end
    end

    add_index :organizations_users, %i[organization_id user_id], unique: true
  end
end
