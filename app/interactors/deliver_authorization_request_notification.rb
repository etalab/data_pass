class DeliverAuthorizationRequestNotification < ApplicationInteractor
  def call
    AuthorizationRequestMailer.with(
      params,
    ).public_send(current_authorization_request_state).deliver_later
  end

  private

  def current_authorization_request_state
    context.authorization_request.state
  end

  def params
    (context.authorization_request_mailer_params || {}).merge(
      authorization_request: context.authorization_request,
    )
  end
end
