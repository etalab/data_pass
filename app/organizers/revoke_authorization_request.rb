class RevokeAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :revoke
    context.event_entity = :revocation_of_authorization
  end

  organize CreateRevocationOfAuthorizationModel,
    CreateAuthorizationRequestEventModel,
    ExecuteAuthorizationRequestTransitionWithCallbacks
end
