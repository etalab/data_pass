class ApproveAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :approve
  end

  organize TriggerAuthorizationRequestEvent,
    ExecuteAuthorizationRequestBridge,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
