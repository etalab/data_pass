class AuthorizationRequestTransferPreview < ActionMailer::Preview
  def success
    AuthorizationRequestTransferMailer.with(
      authorization_request_transfer:,
    ).success
  end

  private

  def authorization_request_transfer
    AuthorizationRequestTransfer.new(
      authorization_request: AuthorizationRequest.first,
      from: User.first,
      to: User.second,
    )
  end
end
