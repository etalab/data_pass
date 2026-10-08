class AuthorizationRequestFormFromInstructorBuilder < AuthorizationRequestFormBuilder
  def required?(_attribute, _options)
    false
  end

  def existing_attachments(attribute)
    options.fetch(:instructor_draft_request).attachments_for(attribute)
  end
end
