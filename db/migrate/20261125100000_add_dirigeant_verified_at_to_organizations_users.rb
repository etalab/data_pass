class AddDirigeantVerifiedAtToOrganizationsUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations_users, :dirigeant_verified_at, :datetime
  end
end
