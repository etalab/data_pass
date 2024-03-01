class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :from, null: false, foreign_key: { to_table: :users }
      t.references :authorization_request, null: false, foreign_key: true
      t.text :body, null: false
      t.datetime :sent_at
      t.datetime :read_at

      t.timestamps
    end
  end
end
