class AddAuthorizationToRevocationOfAuthorizations < ActiveRecord::Migration[8.1]
  def change
    add_reference :revocation_of_authorizations, :authorization, foreign_key: true, null: true
  end
end
