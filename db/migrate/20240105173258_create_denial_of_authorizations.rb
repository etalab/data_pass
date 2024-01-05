class CreateDenialOfAuthorizations < ActiveRecord::Migration[7.1]
  def change
    create_table :denial_of_authorizations do |t|
      t.string :reason, null: false
      t.references :authorization_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
