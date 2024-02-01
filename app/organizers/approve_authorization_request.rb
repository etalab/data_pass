class ApproveAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :approve
    context.event_entity = :authorization
  end

  organize TriggerAuthorizationRequestEvent,
    ExecuteAuthorizationRequestBridge,
    CreateAuthorization,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
