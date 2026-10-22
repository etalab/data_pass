class ApproveAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.api_application_name = context.oauth_application.name
  end

  organize FindInstructorForAPIApproval,
    EnsureAuthorizationRequestIsApprovableFromAPI,
    ApproveAuthorizationRequest
end
