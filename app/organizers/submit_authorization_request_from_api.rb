class SubmitAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.user = context.authorization_request.applicant
    context.authorization_request_params = context.consentement
    context.api_application_name = context.oauth_application.name
  end

  organize EnsureAuthorizationRequestIsSubmittable,
    EnsureConsentsGiven,
    SubmitAuthorizationRequest
end
