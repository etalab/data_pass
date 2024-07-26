module AuthorizationRequestsHelpers
  def start_authorization_request_form(form, disabled: false)
    text = t('start_authorization_request_form.cta', authorization_name: form.authorization_definition.name)
    css_classes = %w[fr-btn fr-icon-save-line fr-btn--icon-left]

    if disabled
      button_tag(text, class: css_classes, disabled: true, id: dom_id(form, :start_authorization_request))
    else
      link_to(text, start_authorization_request_forms_path(form_uid: form.id), class: css_classes, id: dom_id(form, :start_authorization_request))
    end
  end

  def authorization_request_form(authorization_request, url: nil, &)
    authorization_request_form_tag(authorization_request, url:) do |f|
      render(layout: 'authorization_request_forms/form', locals: { f: }) do
        yield f
      end
    end
  end

  def within_wizard?
    new_multiple_steps_form? ||
      defined?(wizard_path) == 'method'
  end

  def within_edit?
    defined?(block_id)
  end

  def english_step_name(translated_step_key = nil)
    if translated_step_key.nil?
      @authorization_request.form.steps.first[:name]
    else
      I18n.t('wicked').select { |_k, v| v == translated_step_key }.keys.first
    end
  end

  private

  def new_multiple_steps_form?
    @authorization_request.form.multiple_steps? &&
      @authorization_request.new_record?
  end

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

  def hubee_dila_selected_scopes_for_current_organization(authorization_request = nil)
    authorization_requests = AuthorizationRequest.where(type: 'AuthorizationRequest::HubEEDila', organization: current_organization.id, state: %w[draft validated submitted changes_requested])

    authorization_requests = authorization_requests.where.not(id: authorization_request.id) if authorization_request.present?

    authorization_requests.map(&:scopes).flatten.uniq.join(', ')
  end
end
