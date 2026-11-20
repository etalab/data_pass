module AuthorizationRequestFormsHelper
  def contact_email_fields(authorization_request)
    authorization_request.contact_types.map { |contact_type| :"#{contact_type}_email" }
  end

  def authorization_request_form_layout(authorization_request)
    definition_layout = "authorization_request_forms/#{authorization_request.definition.id}/form"

    lookup_context.exists?(definition_layout, [], true) ? definition_layout : 'authorization_request_forms/form'
  end

  def archive_modal_buttons_partial(authorization_request)
    definition_buttons = "archive_authorization_requests/#{authorization_request.definition.id}/buttons"

    lookup_context.exists?(definition_buttons, [], true) ? definition_buttons : 'archive_authorization_requests/buttons'
  end

  def render_custom_form_or_default(authorization_request, block, locals = {})
    render partial: "authorization_request_forms/blocks/#{authorization_request.form.uid.tr('-', '_')}/#{block}", locals:
  rescue ActionView::MissingTemplate
    begin
      render partial: "authorization_request_forms/blocks/#{authorization_request.definition.id}/#{block}", locals:
    rescue ActionView::MissingTemplate
      render partial: "authorization_request_forms/blocks/default/#{block}", locals:
    end
  end
end
