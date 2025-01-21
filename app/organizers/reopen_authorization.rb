class ReopenAuthorization < ApplicationOrganizer
  before do
    context.state_machine_event = :reopen
    context.event_entity = :authorization
    context.authorization_request = context.authorization.request
  end

  organize TransitionAuthorizationRequestToPreviousStage, ExecuteAuthorizationRequestTransitionWithCallbacks
end
