class CreateVerifiedEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :verified_emails do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :status, null: false, default: 'unknown'
      t.datetime :verified_at

      t.timestamps
    end
  end
end
