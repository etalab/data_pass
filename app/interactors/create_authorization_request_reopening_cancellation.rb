class CreateAuthorizationRequestReopeningCancellation < ApplicationInteractor
  before do
    context.authorization_request_reopening_cancellation_params ||= {}
  end

  def call
    context.authorization_request_reopening_cancellation = context.authorization_request.reopening_cancellations.build(
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
    context.authorization_request_reopening_cancellation_params.merge(
      user: context.user,
    )
  end
end
