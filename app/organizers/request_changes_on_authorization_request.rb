class RequestChangesOnAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :request_changes
    context.event_entity = :instructor_modification_request
  end

  organize CreateInstructorModificationRequestModel,
    CreateAuthorizationRequestEventModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks
end
