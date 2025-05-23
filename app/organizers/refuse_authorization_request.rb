class RefuseAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :refuse
    context.event_entity = :denial_of_authorization
    context.authorization_request_notifier_params = {
      within_reopening: context.authorization_request.reopening?
    }
  end

  organize CreateDenialOfAuthorizationModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks,
    RestoreAuthorizationRequestToLatestAuthorization
end
