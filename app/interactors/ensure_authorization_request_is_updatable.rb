class EnsureAuthorizationRequestIsUpdatable < ApplicationInteractor
  def call
    return unless context.authorization_request.in_terminal_state?

    fail_with_error(:dead_end_state)
  end
end
