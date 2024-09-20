class CreateBulkAuthorizationRequestUpdates < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_authorization_request_updates do |t|
      t.string :authorization_definition_uid, null: false
      t.string :reason, null: false
      t.date :application_date, null: false

      t.timestamps
    end
  end
end
