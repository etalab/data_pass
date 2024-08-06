class AddSlugsToAuthorizations < ActiveRecord::Migration[7.1]
  def change
    add_column :authorizations, :slug, :string
    add_index :authorizations, %i[slug request_id], unique: true
  end
end
