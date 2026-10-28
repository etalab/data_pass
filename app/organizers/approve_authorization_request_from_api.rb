class ApproveAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.api_application_name = context.oauth_application.name
  end

  around do |organizer|
    context.authorization_request.with_lock { organizer.call }
  end

  organize FindInstructorForAPIApproval,
    EnsureAuthorizationRequestIsApprovableFromAPI,
    ApproveAuthorizationRequest
end
