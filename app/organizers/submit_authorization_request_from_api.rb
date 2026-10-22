class SubmitAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.user = context.authorization_request.applicant
    context.api_application_name = context.oauth_application.name
  end

  organize EnsureAuthorizationRequestIsSubmittable,
    EnsureConsentsGiven,
    AssignConsentsToAuthorizationRequest,
    SubmitAuthorizationRequest
end
