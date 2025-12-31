class AddMessageToAuthorizations < ActiveRecord::Migration[8.1]
  def change
    add_column :authorizations, :message, :text
  end
end
