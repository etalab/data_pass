class ApproveAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :approve
    context.event_entity = :authorization
    context.authorization_request_notifier_params = {
      within_reopening: context.authorization_request.reopening?
    }
  end

  organize CreateAuthorization,
    DeprecatePreviousAuthorizations,
    ExecuteAuthorizationRequestTransitionWithCallbacks,
    ExecuteAuthorizationRequestBridge
end
