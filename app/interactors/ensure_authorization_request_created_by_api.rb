class EnsureAuthorizationRequestCreatedByAPI < ApplicationInteractor
  def call
    return if context.authorization_request.events_without_bulk_update.exists?(name: 'create_by_api')

    fail_with_error(:not_created_by_api)
  end
end
