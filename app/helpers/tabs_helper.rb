module TabsHelper
  def authorization_request_tabs(authorization_request)
    AuthorizationRequestTabsBuilder.new(authorization_request, policy(authorization_request)).build
  end

  def authorization_tabs(authorization)
    AuthorizationTabsBuilder.new(authorization, policy(authorization)).build
  end

  def show_authorization_request_tabs?(authorization_request)
    return false if authorization_request.nil?

    authorization_request.persisted? && authorization_request.state != 'draft'
  end

  def show_authorization_tabs?(authorization)
    authorization.present?
  end
end
