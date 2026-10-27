class ApproveAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.api_application_name = context.oauth_application.name
    context.event_source = 'api'
    context.notification_action = 'approve'
  end

  around do |organizer|
    context.authorization_request.with_lock { organizer.call }
  end

  organize ValidateNotificationsParam,
    ResolveNotificationPolicy,
    FindInstructorForAPIApproval,
    EnsureAuthorizationRequestIsApprovableFromAPI,
    ApproveAuthorizationRequest,
    RecordNotificationPolicyOnEvent
end
