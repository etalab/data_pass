class RestoreAuthorizationRequestToLatestAuthorization < RestoreAuthorizationRequestToAuthorization
  delegate :latest_authorization, to: :authorization_request, private: true

  protected

  def authorization
    latest_authorization
  end

  def authorization_request_params
    ActionController::Parameters.new(latest_authorization_attributes)
  end

  def latest_authorization_attributes
    latest_authorization.data.each_with_object({}) do |(key, _), acc|
      next unless latest_authorization.request_as_validated.respond_to?(key)

      acc[key] = latest_authorization.request_as_validated.public_send(key)
    end
  end
end
