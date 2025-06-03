class AddIdentityProviderUidToOrganizationsUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :organizations_users, bulk: true do |t|
      t.string :identity_provider_uid, null: false, default: '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
