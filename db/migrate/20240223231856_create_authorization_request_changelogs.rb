class CreateAuthorizationRequestChangelogs < ActiveRecord::Migration[7.1]
  def change
    create_table :authorization_request_changelogs do |t|
      t.json :diff, default: {}
      t.references :authorization_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
