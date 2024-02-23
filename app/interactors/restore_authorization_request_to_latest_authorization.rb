class RestoreAuthorizationRequestToLatestAuthorization < ApplicationInteractor
  def call
    return if latest_authorization.nil?

    authorization_request.data = latest_authorization.data
    authorization_request.save
  end

  private

  def authorization_request
    context.authorization_request
  end

  def latest_authorization
    authorization_request.latest_authorization
  end
end
