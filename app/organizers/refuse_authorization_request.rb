class RefuseAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :refuse
    context.event_entity = :denial_of_authorization
  end

  organize CreateDenialOfAuthorizationModel,
    CreateAuthorizationRequestEventModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks,
    RestoreAuthorizationRequestToLatestAuthorization
end
