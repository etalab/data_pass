class SendAuthorizationRequestTransferEmailToUsers < ApplicationInteractor
  def call
    AuthorizationRequestTransferMailer.with(
      authorization_request_transfer: context.authorization_request_transfer,
    ).success.deliver_later
  end
end
