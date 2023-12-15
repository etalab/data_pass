def find_form_from_name(name)
  AuthorizationRequestForm.where(name:).first
end
