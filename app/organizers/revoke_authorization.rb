class RevokeAuthorization < ApplicationOrganizer
  before do
    context.state_machine_event = :revoke
    context.event_name = :revoke
    context.event_entity = :revocation_of_authorization
    context.authorization_request = context.authorization.request
  end

  organize CreateRevocationOfAuthorizationModel,
    MarkAuthorizationAsRevoked,
    TransitionAuthorizationRequestToRevokedIfNeeded,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification,
    ExecuteAuthorizationRequestBridge,
    RevokeChildAuthorizations
end
