class EnsureAuthorizationRequestIsApprovableFromAPI < ApplicationInteractor
  def call
    return if context.authorization_request.submitted?

    fail_with_error(:not_approvable_from_api)
  end
end
