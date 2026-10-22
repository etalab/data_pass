class EnsureAuthorizationRequestIsSubmittable < ApplicationInteractor
  def call
    return if context.authorization_request.can_submit?

    fail_with_error(:dead_end_state)
  end
end
