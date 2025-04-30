class RequestChangesOnAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :request_changes
    context.event_entity = :instructor_modification_request
    context.authorization_request_notifier_params = {
      reopening_params: context.authorization_request.reopening?
    }
  end

  organize CreateInstructorModificationRequestModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks
end
