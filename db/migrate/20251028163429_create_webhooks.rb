class CreateWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :webhooks do |t|
      t.string :authorization_definition_id, null: false
      t.string :url, null: false
      t.jsonb :events, default: [], null: false
      t.boolean :enabled, default: false, null: false
      t.boolean :validated, default: false, null: false
      t.text :secret, null: false
      t.datetime :activated_at
      t.timestamps
    end

    add_index :webhooks, :authorization_definition_id
    add_index :webhooks, [:authorization_definition_id, :enabled, :validated], name: 'index_webhooks_on_definition_enabled_validated'
  end
end
