class FranceConnectMailerPreview < ActionMailer::Preview
  def new_scopes
    FranceConnectMailer.with(authorization_request:).new_scopes
  end

  private

  def authorization_request
    AuthorizationRequest::APIImpotParticulierSandbox.where(state: :validated).last
  end
end
