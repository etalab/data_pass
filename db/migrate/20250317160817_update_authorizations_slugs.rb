class UpdateAuthorizationsSlugs < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      -- Update existing slugs by prepending authorization_request_id
      UPDATE authorizations
      SET slug = CONCAT(request_id, '--', slug);
    SQL
  end

  def down
    execute <<-SQL
      -- Restore original slugs by removing the prepended authorization_request_id
      UPDATE authorizations
      SET slug = substring(slug from position('--' in slug) + 2);
    SQL
  end
end