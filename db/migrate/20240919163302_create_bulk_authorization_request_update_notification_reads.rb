class CreateBulkAuthorizationRequestUpdateNotificationReads < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_authorization_request_update_notification_reads do |t|
      t.references :bulk_authorization_request_update, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.index [:bulk_authorization_request_update_id, :user_id], unique: true

      t.timestamps
    end
  end
end
