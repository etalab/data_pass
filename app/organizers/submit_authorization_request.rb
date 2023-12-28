class SubmitAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :submit
  end

  organize UpdateAuthorizationRequest,
    TriggerAuthorizationRequestEvent

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
