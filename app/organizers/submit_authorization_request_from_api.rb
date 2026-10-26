class SubmitAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.user = context.authorization_request.applicant
    context.api_application_name = context.oauth_application.name
    context.notification_action = 'submit'
  end

  around do |organizer|
    context.authorization_request.with_lock { organizer.call }
  end

  organize ResolveNotificationPolicy,
    EnsureApplicantIsNotBanned,
    EnsureAuthorizationRequestCreatedByAPI,
    EnsureAuthorizationRequestIsSubmittable,
    EnsureConsentsGiven,
    AssignConsentsToAuthorizationRequest,
    SubmitAuthorizationRequest
end
