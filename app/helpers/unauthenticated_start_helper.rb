module UnauthenticatedStartHelper
  def render_custom_start_or_default(authorization_definition)
    render partial: "authorization_requests/unauthenticated_start/#{authorization_definition.id}/start"
  rescue ActionView::MissingTemplate
    render partial: 'authorization_requests/unauthenticated_start/default_start'
  end
end
