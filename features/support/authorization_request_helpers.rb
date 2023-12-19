def find_form_from_name(name)
  AuthorizationRequestForm.where(name:).first
end

def find_factory_trait_from_name(name)
  find_form_from_name(name).authorization_request_class.to_s.underscore.split('/').last
end
