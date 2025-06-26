module DemandesHabilitations::CommonHelper
  def render_custom_block_or_default(authorization_request, block_id, locals = {})
    locals[:f] ||= build_form_builder(authorization_request)

    render partial: "authorization_requests/blocks/#{authorization_request.definition.id}/#{block_id}", locals: { authorization_request:, **locals }
  rescue ActionView::MissingTemplate
    render partial: "authorization_requests/blocks/default/#{block_id}", locals: { authorization_request:, **locals }
  end

  def render_accepted_tos_checkboxes(authorization_request, locals = {})
    locals[:f] ||= build_form_builder(authorization_request)

    render partial: 'demandes_habilitations/accepted_tos_checkboxes', locals: { authorization_request:, **locals }
  end

  private

  def build_form_builder(authorization_request)
    AuthorizationRequestFormBuilder.new(
      'authorization_request',
      authorization_request,
      self,
      {}
    )
  end
end
