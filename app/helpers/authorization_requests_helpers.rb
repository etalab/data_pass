module AuthorizationRequestsHelpers
  def authorization_request_form(authorization_request, &)
    form_with(
      model: authorization_request,
      url: authorization_request_model_path(authorization_request.form, authorization_request),
      method: authorization_request_model_http_method(authorization_request),
      id: dom_id(authorization_request),
      &
    )
  end

  def authorization_request_model_path(authorization_request_form, authorization_request)
    if authorization_request.new_record?
      authorization_requests_path(form_uid: authorization_request_form.uid)
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
