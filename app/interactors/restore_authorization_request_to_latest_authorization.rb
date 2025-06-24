class RestoreAuthorizationRequestToLatestAuthorization < RestoreAuthorizationRequestToAuthorization
  delegate :latest_authorization, to: :authorization_request, private: true

  protected

  def authorization
    latest_authorization
  end

  def authorization_request_params
    ActionController::Parameters.new(latest_authorization.data)
  end
end
