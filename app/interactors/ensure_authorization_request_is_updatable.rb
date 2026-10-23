class EnsureAuthorizationRequestIsUpdatable < ApplicationInteractor
  def call
    return if context.authorization_request.editable_by_applicant?

    fail_with_error(:dead_end_state)
  end
end
