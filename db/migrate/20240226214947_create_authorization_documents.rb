class CreateAuthorizationDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :authorization_documents do |t|
      t.string :identifier, null: false
      t.references :authorization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
