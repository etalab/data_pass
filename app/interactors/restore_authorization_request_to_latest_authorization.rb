class RestoreAuthorizationRequestToLatestAuthorization < RestoreAuthorizationRequestToAuthorization
  delegate :latest_authorization, to: :authorization_request, private: true

  protected

  def authorization
    latest_authorization
  end

  def authorization_request_params
    data = latest_authorization.data.deep_dup
    data['scopes'] = normalize_scopes(data['scopes'])
    ActionController::Parameters.new(data)
  end

  def normalize_scopes(scopes)
    case scopes
    when String
      JSON.parse(scopes)
    when Array
      scopes
    else
      []
    end
  rescue JSON::ParserError
    []
  end
end
