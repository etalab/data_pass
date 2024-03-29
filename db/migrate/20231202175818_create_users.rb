class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :family_name
      t.string :given_name
      t.string :job_title
      t.boolean :email_verified, default: false
      t.string :external_id, index: { unique: true, where: 'external_id IS NOT NULL' }

      t.timestamps
    end
  end
end
