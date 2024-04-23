module AuthorizationRequestsHelpers
  def start_authorization_request_form(form, disabled: false)
    authorization_request_form_tag(form.authorization_request_class.new(form_uid: form.uid)) do |f|
      f.button t('start_authorization_request_form.cta', authorization_name: form.authorization_definition.name), type: :submit, name: :start, id: dom_id(form, :start_authorization_request), class: %w[fr-btn fr-icon-save-line fr-btn--icon-left], disabled:
    end
  end

  def authorization_request_form(authorization_request, url: nil, &)
    authorization_request_form_tag(authorization_request, url:) do |f|
      render(layout: 'authorization_request_forms/form', locals: { f: }) do
        yield f
      end
    end
  end

  private

  def authorization_request_form_tag(authorization_request, url: nil, &)
    form_with(
      model: authorization_request,
      url: url || authorization_request_model_path(authorization_request),
      method: authorization_request_model_http_method(authorization_request),
      id: dom_id(authorization_request),
      builder: authorization_request_can_be_updated?(authorization_request) ? AuthorizationRequestFormBuilder : DisabledAuthorizationRequestFormBuilder, &
    )
  end

  def authorization_request_model_path(authorization_request)
    if namespace?(:instruction)
      '#'
    elsif authorization_request.new_record?
      authorization_request_forms_path(form_uid: authorization_request.form.uid)
    elsif authorization_request.form.multiple_steps? && defined?(wizard_path)
      wizard_path
    else
      authorization_request_form_path(form_uid: authorization_request.form.uid, id: authorization_request.id)
    end
  end

  def authorization_request_model_http_method(authorization_request)
    return if namespace?(:instruction)

    if authorization_request.new_record?
      :post
    else
      :patch
    end
  end

  def authorization_request_can_be_updated?(authorization_request)
    return false if namespace?(:instruction)

    authorization_request.filling?
  end
end
