class AuthorizationRequestPreview < ActionMailer::Preview
  def validated
    AuthorizationRequestMailer.with(authorization_request: AuthorizationRequest.where(state: 'validated').first).validated
  end
end
