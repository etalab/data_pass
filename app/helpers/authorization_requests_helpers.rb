module AuthorizationRequestsHelpers
  def authorization_request_form(authorization_request, &)
    form_with(
      model: authorization_request,
      url: authorization_request_model_path(authorization_request.form, authorization_request),
      method: authorization_request_model_http_method(authorization_request),
      id: dom_id(authorization_request),
      builder: authorization_request.in_draft? ? AuthorizationRequestFormBuilder : DisabledAuthorizationRequestFormBuilder,
      &
    )
  end

  def authorization_request_model_path(authorization_request_form, authorization_request)
    if authorization_request.new_record?
      authorization_requests_path(form_uid: authorization_request_form.uid)
    elsif authorization_request.form.multiple_steps?
      wizard_path
    else
      authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
    end
  end

  def authorization_request_model_http_method(authorization_request)
    if authorization_request.new_record?
      :post
    else
      :patch
    end
  end
end
