class SubmitAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.user = context.authorization_request.applicant
    context.authorization_request_params = context.consentement
  end

  organize EnsureAuthorizationRequestIsSubmittable,
    EnsureConsentsGiven,
    SubmitAuthorizationRequest
end
