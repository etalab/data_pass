class RevokeAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :revoke
    context.event_entity = :denial_of_authorization
  end

  organize CreateDenialOfAuthorizationModel,
    CreateAuthorizationRequestEventModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks
end
