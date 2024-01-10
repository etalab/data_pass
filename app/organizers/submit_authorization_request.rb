class SubmitAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.state_machine_event = :submit
  end

  organize AssignParamsToAuthorizationRequest,
    TriggerAuthorizationRequestEvent,
    CreateAuthorizationRequestEventModel

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
