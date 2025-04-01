class AddStateToAuthorizations < ActiveRecord::Migration[8.0]
  def change
    add_column :authorizations, :state, :string
    add_index :authorizations, :state
  end
end
