class ExecuteAuthorizationRequestTransitionWithCallbacks < ApplicationOrganizer
  organize TriggerAuthorizationRequestEvent,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
