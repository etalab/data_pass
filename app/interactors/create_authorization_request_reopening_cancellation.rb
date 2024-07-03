class CreateAuthorizationRequestReopeningCancellation < ApplicationInteractor
  def call
    context.authorization_request_reopening_cancellation = AuthorizationRequestReopeningCancellation.new(
      authorization_request_reopening_cancellation_params,
    )

    return if context.authorization_request_reopening_cancellation.save

    context.fail!(error: :invalid_reopening_cancellation)
  end

  def rollback
    context.authorization_request_reopening_cancellation.destroy
  end

  private

  def authorization_request_reopening_cancellation_params
    {
      request: context.authorization_request,
      reason: context.reason,
      user: context.user,
    }
  end
end
