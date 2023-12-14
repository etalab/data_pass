module ApplicationHelper
  def provider_logo_path(authorization_request_form)
    "authorization_request_forms_logos/#{authorization_request_form.logo}"
  end
end
