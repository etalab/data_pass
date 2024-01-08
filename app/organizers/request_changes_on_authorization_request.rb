class RequestChangesOnAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :request_changes
  end

  organize CreateInstructorModificationRequestModel,
    TriggerAuthorizationRequestEvent,
    DeliverAuthorizationRequestNotification
end
