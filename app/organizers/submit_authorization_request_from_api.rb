class SubmitAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.user = context.authorization_request.applicant
  end

  organize EnsureAuthorizationRequestIsSubmittable,
    EnsureConsentsGiven,
    AssignConsentsToAuthorizationRequest,
    SubmitAuthorizationRequest
end
