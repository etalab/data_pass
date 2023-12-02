class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :siret, null: false, index: { unique: true }
      t.jsonb :mon_compte_pro_payload, null: false, default: {}
      t.datetime :last_mon_compte_pro_updated_at, null: false

      t.timestamps
    end

    create_table :organizations_users, id: false do |t|
      t.belongs_to :organization, index: true
      t.belongs_to :user, index: true
    end
  end
end
