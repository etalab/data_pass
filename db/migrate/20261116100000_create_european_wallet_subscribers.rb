class CreateEuropeanWalletSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :european_wallet_subscribers do |t|
      t.string :email, null: false
      t.string :profile, null: false

      t.timestamps
    end

    add_index :european_wallet_subscribers, :email, unique: true
    add_index :european_wallet_subscribers, :profile
  end
end
