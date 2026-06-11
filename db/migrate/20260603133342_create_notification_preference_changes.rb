class CreateNotificationPreferenceChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preference_changes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :authorization_definition_id, null: false
      t.string :kind, null: false
      t.boolean :enabled, null: false
      t.string :source, null: false
      t.timestamps
    end
  end
end
