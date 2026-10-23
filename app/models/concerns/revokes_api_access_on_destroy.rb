module RevokesAPIAccessOnDestroy
  extend ActiveSupport::Concern

  included do
    before_destroy :revoke_api_access_grants, prepend: true
  end

  private

  def revoke_api_access_grants
    APIAccessGrant.active.where(oauth_application_id: id).find_each do |grant|
      throw :abort unless grant.revoke_automatically!(reason: I18n.t('api_access_grants.revoked_on_application_deletion'))
    end
  end
end
