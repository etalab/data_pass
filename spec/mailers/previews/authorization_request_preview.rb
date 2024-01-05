class AuthorizationRequestPreview < ActionMailer::Preview
  def validated
    AuthorizationRequestMailer.with(authorization_request: AuthorizationRequest.where(state: 'validated').first).validated
  end

  def refused
    AuthorizationRequestMailer.with(authorization_request: AuthorizationRequest.where(state: 'refused').first).refused
  end
end
