module AuthorizationRequestFormsHelper
  def contact_email_fields(authorization_request)
    authorization_request.contact_types.map { |contact_type| :"#{contact_type}_email" }
  end
end
