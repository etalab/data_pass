class AuthorizationRequestTransferMailer < ApplicationMailer
  def success
    @authorization_request_transfer = params[:authorization_request_transfer]
    @authorization_request = @authorization_request_transfer.authorization_request

    mail(
      to: [@authorization_request_transfer.to.email, @authorization_request_transfer.from.email],
      subject: t('.subject', authorization_request_id: @authorization_request_transfer.authorization_request.id)
    )
  end
end
