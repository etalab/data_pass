class ReopenAuthorization < ApplicationOrganizer
  before do
    context.state_machine_event = :reopen
    context.event_entity = :authorization
    context.authorization_request = context.authorization.request
    context.authorization_request.assign_attributes(reopened_at: DateTime.now)
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks
end
