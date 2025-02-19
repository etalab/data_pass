class FranceConnectMailerPreview < ActionMailer::Preview
  def new_scopes
    FranceConnectMailer.with(authorization_request:).new_scopes
  end

  private

  def authorization_request
    AuthorizationRequest::APIDroitsCNAM.where(state: 'validated').first
  end
end
