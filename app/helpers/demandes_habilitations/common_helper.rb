module DemandesHabilitations::CommonHelper
  def render_custom_block_or_default(authorization_request, block_id, locals = {})
    render partial: "authorization_requests/blocks/#{authorization_request.definition.id}/#{block_id}", locals: { authorization_request:, **locals }
  rescue ActionView::MissingTemplate
    render partial: "authorization_requests/blocks/default/#{block_id}", locals: { authorization_request:, **locals }
  end
end
