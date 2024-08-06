class CreateAuthorizationRequestReopeningCancellations < ActiveRecord::Migration[7.1]
  def change
    create_table :authorization_request_reopening_cancellations do |t|
      t.text :reason
      t.references :request, null: false, foreign_key: { to_table: :authorization_requests }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
