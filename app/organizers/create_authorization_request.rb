class CreateAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create'
    context.authorization_request = context.authorization_request_form.authorization_request_class.new
  end

  organize AssignDefaultDataToAuthorizationRequest,
    CreateAuthorizationRequestModel,
    AssignParamsToAuthorizationRequest,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestWebhook

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
