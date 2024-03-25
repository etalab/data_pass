class CreateAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create'
  end

  organize CreateAuthorizationRequestModel,
    AssignDefaultDataToAuthorizationRequest,
    CreateAuthorizationRequestEventModel,
    AssignParamsToAuthorizationRequest,
    DeliverAuthorizationRequestWebhook

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
