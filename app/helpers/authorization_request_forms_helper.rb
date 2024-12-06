module AuthorizationRequestFormsHelper
  def contact_email_fields(authorization_request)
    authorization_request.contact_types.map { |contact_type| :"#{contact_type}_email" }
  end

  def render_custom_form_or_default(authorization_request, block, locals = {})
    render partial: "authorization_request_forms/blocks/#{authorization_request.definition.id}/#{block}", locals:
  rescue ActionView::MissingTemplate
    render partial: "authorization_request_forms/blocks/default/#{block}", locals:
  end
end
