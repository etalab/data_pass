class RemoveNonNullConstraintForRedirectUriOnOauthApplications < ActiveRecord::Migration[8.0]
  def up
    change_column_null :oauth_applications, :redirect_uri, true
  end

  def down; end
end
