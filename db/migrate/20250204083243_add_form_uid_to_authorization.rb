class AddFormUidToAuthorization < ActiveRecord::Migration[8.0]
  def change
    add_column :authorizations, :form_uid, :string
  end
end
