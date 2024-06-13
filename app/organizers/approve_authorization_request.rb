class ApproveAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :approve
    context.event_entity = :authorization
    context.authorization_request_notifier_params = {
      first_validation: !context.authorization_request.already_been_validated?
    }
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks,
    CreateAuthorization,
    CreateAuthorizationRequestEventModel,
    ExecuteAuthorizationRequestBridge,
    DeliverGDPRContactsMails
end
