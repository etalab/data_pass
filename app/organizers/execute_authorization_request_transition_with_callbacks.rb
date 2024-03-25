class ExecuteAuthorizationRequestTransitionWithCallbacks < ApplicationOrganizer
  organize TriggerAuthorizationRequestEvent,
    DeliverAuthorizationRequestNotification,
    DeliverAuthorizationRequestWebhook
end
