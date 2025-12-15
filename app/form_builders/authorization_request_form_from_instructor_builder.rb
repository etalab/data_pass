class AuthorizationRequestFormFromInstructorBuilder < AuthorizationRequestFormBuilder
  def required?(_attribute, _options)
    false
  end
end
