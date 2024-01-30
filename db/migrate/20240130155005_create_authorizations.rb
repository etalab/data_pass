class CreateAuthorizations < ActiveRecord::Migration[7.1]
  def change
    create_table :authorizations do |t|
      t.hstore :data, default: {}, null: false
      t.references :applicant, null: false, foreign_key: { to_table: :users }
      t.references :authorization_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
