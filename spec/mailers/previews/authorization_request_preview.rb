class AuthorizationRequestPreview < ActionMailer::Preview
  %w[validated refused changes_requested].each do |state|
    define_method state do
      authorization_request_mailer_method(state)
    end
  end

  private

  def authorization_request_mailer_method(state)
    AuthorizationRequestMailer.with(
      authorization_request: AuthorizationRequest.where(state:).first
    ).public_send(state)
  end
end
