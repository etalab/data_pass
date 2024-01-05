class RefuseAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :refuse
  end

  organize CreateDenialOfAuthorizationModel,
    TriggerAuthorizationRequestEvent,
    DeliverAuthorizationRequestNotification
end
