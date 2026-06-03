class FranceConnectMailerPreview < ActionMailer::Preview
  def new_scopes
    FranceConnectMailer.with(authorization_request:).new_scopes
  end

  def new_scopes_reopening
    FranceConnectMailer.with(authorization_request: reopened_authorization_request).new_scopes
  end

  private

  def authorization_request
    AuthorizationRequest::APIImpotParticulierSandbox.where(state: :validated).last
  end

  def reopened_authorization_request
    AuthorizationRequest::APIImpotParticulierSandbox.where.not(reopened_at: nil).where(state: :submitted).last
  end
end
