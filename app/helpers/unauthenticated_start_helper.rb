module UnauthenticatedStartHelper
  def render_custom_start_or_default(authorization_definition)
    custom_start = "authorization_requests/unauthenticated_start/#{authorization_definition.id}/start"

    if lookup_context.exists?(custom_start, [], true)
      render partial: custom_start
    else
      render partial: 'authorization_requests/unauthenticated_start/default_start'
    end
  end
end
