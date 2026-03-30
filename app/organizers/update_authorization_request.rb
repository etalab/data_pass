class UpdateAuthorizationRequest < ApplicationOrganizer
  before do
    context.event_name = 'update'
    context.save_context ||= :update
  end

  organize AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    VerifyContactsEmailsAsynchronously,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification

  after do
    context.authorization_request.save(context: context.save_context) ||
      context.fail!
  end
end
