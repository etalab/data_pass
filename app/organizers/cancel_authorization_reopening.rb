class CancelAuthorizationReopening < ApplicationOrganizer
  before do
    context.state_machine_event = :cancel_reopening
    context.event_entity = :authorization_request_reopening_cancellation
  end

  organize CreateAuthorizationRequestReopeningCancellation,
    RestoreAuthorizationRequestToLatestAuthorization,
    ExecuteAuthorizationRequestTransitionWithCallbacks
end
