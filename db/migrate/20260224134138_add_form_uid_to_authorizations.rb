class AddFormUidToAuthorizations < ActiveRecord::Migration[8.1]
  def change
    add_column :authorizations, :form_uid, :string
  end
end
