class Admin::SyncAPIAccessScopes < ApplicationInteractor
  def call
    application = context.grant.oauth_application
    return if application.nil?

    application.with_lock do
      application.update!(scopes: synced_scopes(application))
    end
  end

  private

  def synced_scopes(application)
    unmanaged = (starting_scopes(application) & configured_scopes) - APIScopes::ALL

    (unmanaged + granted_scopes(application)).join(' ')
  end

  def starting_scopes(application)
    explicit_scopes = application.scopes.to_a

    explicit_scopes.presence || configured_scopes
  end

  def configured_scopes
    Doorkeeper.config.scopes.to_a
  end

  def granted_scopes(application)
    APIAccessGrant
      .active
      .where(oauth_application_id: application.id)
      .distinct
      .order(:action)
      .pluck(:action)
      .map { |action| APIScopes::BY_ACTION.fetch(action) }
  end
end
