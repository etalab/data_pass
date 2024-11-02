class AddAuthorizationRequestClassToAuthorizations < ActiveRecord::Migration[7.2]
  def up
    add_column :authorizations, :authorization_request_class, :string

    Authorization.includes(:request).find_each do |authorization|
      authorization.update!(authorization_request_class: authorization.request.class.name)
    end

    change_column_null :authorizations, :authorization_request_class, false
  end

  def down
    remove_column :authorizations, :authorization_request_class
  end
end
