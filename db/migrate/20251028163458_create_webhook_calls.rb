class CreateWebhookCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_calls do |t|
      t.references :webhook, null: false, foreign_key: true
      t.references :authorization_request, null: false, foreign_key: true
      t.string :event_name, null: false, index: true
      t.integer :status_code
      t.text :response_body
      t.jsonb :payload, default: {}, null: false
      t.timestamps
    end

    add_index :webhook_calls, :created_at
    add_index :webhook_calls, [:webhook_id, :created_at], order: { created_at: :desc }
  end
end
